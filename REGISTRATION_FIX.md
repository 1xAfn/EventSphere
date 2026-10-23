# Registration Fix

## Problem
Registration was not working - users couldn't be registered successfully.

## Root Causes
1. **Trigger Conflict**: Database trigger `handle_new_user` automatically creates a profile, but the app code was also trying to create one, causing conflicts
2. **RLS Policy Issues**: Row Level Security policies might block profile creation
3. **Error Handling**: Errors weren't being caught and displayed properly

## Fixes Applied

### 1. Updated SignUp Method
- Now passes `role` in user metadata
- This allows the trigger to create profile with correct role

### 2. Updated createProfile Method
- Checks if profile already exists (from trigger)
- If exists: Updates it with correct role and approval status
- If not exists: Creates new profile
- Handles conflicts gracefully

### 3. Enhanced Registration Screen
- Better error handling and messages
- Verifies profile was created after registration
- More specific error messages for different scenarios
- Handles rate limiting better

### 4. Database Fixes
- Created `FIX_REGISTRATION.sql` to:
  - Fix profile insert policies
  - Update trigger to handle conflicts
  - Ensure trigger is active

## Setup Instructions

### Step 1: Run Database Fix
**IMPORTANT**: Run this first!

1. Open Supabase Dashboard
2. Go to SQL Editor
3. Copy and paste contents of `FIX_REGISTRATION.sql`
4. Run the script
5. Verify trigger exists and policies are correct

### Step 2: Test Registration
1. Try registering a new user
2. Check for success message
3. Verify user is created in `auth.users` table
4. Verify profile is created in `profiles` table
5. Try logging in with new credentials

## How It Works Now

### Registration Flow:
```
User fills form and clicks Register
    ↓
signUp() called with email, password, and role in metadata
    ↓
Supabase creates user in auth.users
    ↓
Trigger handle_new_user fires automatically
    ↓
Trigger creates profile in profiles table
    ↓
App code updates profile with correct role/approval
    ↓
Success message shown
    ↓
Redirect to login page
```

### Error Handling:
- **Rate Limiting**: Shows friendly message to wait
- **Duplicate Email**: Suggests logging in instead
- **Invalid Email**: Shows validation error
- **Password Issues**: Shows password requirements
- **RLS Errors**: Shows database permission error
- **Other Errors**: Shows first 150 characters of error

## Troubleshooting

### If Registration Still Fails:

1. **Check Supabase Auth Settings**:
   - Go to Authentication > Settings
   - Ensure "Enable email confirmations" is set appropriately
   - For testing, you might want to disable email confirmation

2. **Check Trigger**:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
   ```
   Should return the trigger

3. **Check Policies**:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'profiles';
   ```
   Should show insert policy allowing users to create their own profile

4. **Check Console**:
   - Run app with `flutter run`
   - Check console for detailed error messages
   - Look for Supabase errors

5. **Manual Test**:
   - Try creating a user directly in Supabase Dashboard
   - Check if trigger creates profile automatically
   - Verify RLS policies allow the operation

## Common Issues

### Issue: "Profile creation failed"
**Solution**: Run `FIX_REGISTRATION.sql` to fix trigger and policies

### Issue: "User created but profile missing"
**Solution**: 
- Check if trigger is active
- Manually create profile if needed
- Verify RLS policies

### Issue: "Rate limiting error"
**Solution**: 
- Wait 36 seconds between registration attempts
- Error message will tell you to wait

### Issue: "Email already exists"
**Solution**: 
- User should login instead
- Or use a different email

## Verification

After running `FIX_REGISTRATION.sql`, verify:

1. **Trigger exists**:
   ```sql
   SELECT routine_name FROM information_schema.routines 
   WHERE routine_name = 'handle_new_user';
   ```

2. **Policies exist**:
   ```sql
   SELECT policyname FROM pg_policies 
   WHERE tablename = 'profiles' AND cmd = 'INSERT';
   ```

3. **Test registration**:
   - Register a new user
   - Check `auth.users` table - user should exist
   - Check `profiles` table - profile should exist with correct role

## Files Modified

1. `lib/Services/supabase_service.dart`:
   - Updated `signUp()` to pass role in metadata
   - Updated `createProfile()` to handle existing profiles

2. `lib/Screens/register_screen.dart`:
   - Enhanced error handling
   - Added profile verification
   - Better error messages

3. `FIX_REGISTRATION.sql` (NEW):
   - Database fixes for trigger and policies

Registration should now work properly! 🎉

