-- Fix RLS Policies for Notifications and Reviews
-- Run this in Supabase SQL Editor to fix the errors

-- ============================================
-- FIX NOTIFICATIONS RLS POLICY
-- ============================================
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;

-- Create new policies that allow system inserts
CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Allow system to insert notifications (for booking confirmations)
-- This uses SECURITY DEFINER to bypass RLS for inserts
CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- Alternative: Allow authenticated users to insert notifications
-- (if the above doesn't work, use this instead)
-- CREATE POLICY "Authenticated users can insert notifications"
--   ON notifications FOR INSERT
--   WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- FIX REVIEWS QUERY (No schema change needed)
-- ============================================
-- The reviews table is fine, but we need to ensure the foreign key exists
-- Check if foreign key exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'reviews_user_id_fkey'
  ) THEN
    ALTER TABLE reviews
    ADD CONSTRAINT reviews_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
  END IF;
END $$;

-- ============================================
-- VERIFY POLICIES
-- ============================================
-- Check notifications policies
SELECT * FROM pg_policies WHERE tablename = 'notifications';

-- Check reviews policies  
SELECT * FROM pg_policies WHERE tablename = 'reviews';

