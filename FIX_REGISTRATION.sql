-- Fix Registration Issues
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. FIX PROFILE INSERT POLICY
-- ============================================
-- Drop existing insert policy
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- Create a more permissive policy that allows profile creation during signup
CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Also allow the trigger to insert profiles (SECURITY DEFINER already handles this)
-- But ensure the policy doesn't block it

-- ============================================
-- 2. UPDATE TRIGGER TO HANDLE ROLE BETTER
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert profile with role from metadata, or default to 'client'
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
    is_approved = COALESCE(EXCLUDED.is_approved, profiles.is_approved);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 3. VERIFY TRIGGER EXISTS
-- ============================================
-- Drop and recreate trigger to ensure it's active
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 4. CHECK EXISTING POLICIES
-- ============================================
-- View all policies on profiles table
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- ============================================
-- 5. TEST QUERY (Optional - to verify setup)
-- ============================================
-- This should return the trigger function
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'handle_new_user';

-- ============================================
-- NOTES:
-- ============================================
-- 1. The trigger will automatically create a profile when a user signs up
-- 2. The app code will then update the profile with the correct role
-- 3. If trigger fails, the app code will create the profile manually
-- 4. The ON CONFLICT clause ensures no duplicate key errors

