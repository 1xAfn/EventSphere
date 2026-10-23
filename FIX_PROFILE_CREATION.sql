-- Comprehensive Fix for Profile Creation
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. DROP ALL EXISTING POLICIES ON PROFILES
-- ============================================
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- ============================================
-- 2. CREATE NEW POLICIES (More Permissive)
-- ============================================

-- Allow users to view their own profile
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow users to insert their own profile (during registration)
CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Allow users to view any profile (for public info like names in reviews)
CREATE POLICY "Anyone can view profiles"
  ON profiles FOR SELECT
  USING (true);

-- ============================================
-- 3. FIX TRIGGER FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert profile with role from metadata, or default to 'client'
  -- Use ON CONFLICT to handle cases where profile already exists
  INSERT INTO public.profiles (id, full_name, role, is_approved)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client'),
    CASE 
      WHEN COALESCE(NEW.raw_user_meta_data->>'role', 'client') = 'client' THEN true
      ELSE false
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    role = COALESCE(EXCLUDED.role, profiles.role),
    is_approved = COALESCE(EXCLUDED.is_approved, profiles.is_approved),
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. RECREATE TRIGGER
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 5. CREATE HELPER FUNCTION FOR PROFILE CREATION
-- ============================================
-- This function can be called from the app if needed
CREATE OR REPLACE FUNCTION public.create_user_profile(
  user_id UUID,
  user_role TEXT DEFAULT 'client',
  user_approved BOOLEAN DEFAULT false
)
RETURNS void AS $$
BEGIN
  INSERT INTO public.profiles (id, role, is_approved)
  VALUES (user_id, user_role, user_approved)
  ON CONFLICT (id) DO UPDATE SET
    role = COALESCE(EXCLUDED.role, profiles.role),
    is_approved = COALESCE(EXCLUDED.is_approved, profiles.is_approved);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile TO authenticated;

-- ============================================
-- 6. VERIFY SETUP
-- ============================================
-- Check trigger exists
SELECT 
  tgname as trigger_name,
  tgrelid::regclass as table_name
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- Check policies exist
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as command
FROM pg_policies 
WHERE tablename = 'profiles';

-- Check function exists
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('handle_new_user', 'create_user_profile');

-- ============================================
-- NOTES:
-- ============================================
-- 1. The trigger will automatically create a profile when a user signs up
-- 2. The app can also call create_user_profile() function if needed
-- 3. ON CONFLICT ensures no duplicate key errors
-- 4. SECURITY DEFINER allows the function to bypass RLS
-- 5. The "Anyone can view profiles" policy allows public profile viewing

