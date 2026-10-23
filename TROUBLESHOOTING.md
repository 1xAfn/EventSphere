# Troubleshooting Guide

## Common Issues and Solutions

### 1. App Stuck on Loading Screen

**Symptoms**: Loading indicator shows but nothing loads, no events appear

**Possible Causes**:
- Database connection issue
- No data in database
- RLS (Row Level Security) policies blocking access
- Missing tables

**Solutions**:

1. **Check Database Connection**:
   - Verify Supabase URL and anon key in `lib/main.dart`
   - Check if Supabase project is active
   - Test connection in Supabase dashboard

2. **Verify Database Schema**:
   - Run `SUPABASE_SCHEMA.sql` in Supabase SQL Editor
   - Check that all tables exist: `events`, `profiles`, `services`, etc.
   - Verify RLS policies are enabled and configured

3. **Check for Data**:
   - Go to Supabase Dashboard > Table Editor
   - Verify `events` table has data
   - If empty, create test events manually or through the app

4. **Check RLS Policies**:
   - Go to Supabase Dashboard > Authentication > Policies
   - Ensure `events` table has a policy allowing SELECT for all users
   - Policy should be: `Anyone can view events` (as per schema)

5. **Check Console for Errors**:
   - Run `flutter run` and check console output
   - Look for Supabase error messages
   - Common errors: "permission denied", "relation does not exist"

### 2. Navigation Not Working

**Symptoms**: Clicking buttons (Profile, FAQ) doesn't navigate

**Possible Causes**:
- Route not defined
- Error in screen widget
- Navigation context issue

**Solutions**:

1. **Check Routes**:
   - Verify all routes are defined in `lib/main.dart`
   - Routes should include: `/profile`, `/faq`, `/bookings`, etc.

2. **Check for Errors**:
   - Look at console output when clicking buttons
   - Check if screens have errors (null safety, missing imports)

3. **Test Navigation**:
   - Try using `Navigator.pushNamed(context, '/faq')` directly
   - Check if error messages appear

### 3. Profile Screen Not Showing

**Symptoms**: Profile button clicked but screen is blank or shows error

**Possible Causes**:
- Profile doesn't exist in database
- User not authenticated
- Error in profile query

**Solutions**:

1. **Check User Authentication**:
   - Verify user is logged in
   - Check `supabase.auth.currentUser` is not null

2. **Check Profile Exists**:
   - Go to Supabase Dashboard > Table Editor > profiles
   - Verify profile exists for your user ID
   - If missing, create profile manually or re-register

3. **Check Profile Query**:
   - The app queries `profiles` table by user ID
   - Ensure RLS policy allows users to read their own profile

### 4. FAQ Screen Not Showing

**Symptoms**: FAQ button clicked but screen is blank

**Possible Causes**:
- FAQ table is empty
- Database connection issue
- RLS policy blocking access

**Solutions**:

1. **Check FAQ Data**:
   - Go to Supabase Dashboard > Table Editor > faq
   - Add some FAQ entries manually if empty
   - Or use admin panel to add FAQs

2. **Check RLS Policy**:
   - FAQ table should allow SELECT for all users
   - Policy: `Anyone can view FAQ`

3. **Test Query**:
   - Try querying FAQ table directly in Supabase SQL Editor:
   ```sql
   SELECT * FROM faq;
   ```

### 5. No Events Showing

**Symptoms**: Home screen shows "No events found" or stays loading

**Possible Causes**:
- No events in database
- Event type filter too restrictive
- Database connection issue

**Solutions**:

1. **Add Test Events**:
   - Go to Supabase Dashboard > Table Editor > events
   - Insert a test event:
   ```sql
   INSERT INTO events (title, description, venue, price, vendor_id, event_type)
   VALUES ('Test Event', 'Description', 'Venue', 100, 'YOUR_USER_ID', 'Wedding');
   ```

2. **Check Event Type**:
   - Ensure events have `event_type` set: 'Wedding', 'Party', 'Birthday', or 'Seminar'
   - Try selecting "All" filter to see all events

3. **Check Vendor Approval**:
   - If you're a vendor, ensure your profile has `is_approved = true`
   - Only approved vendors can create events

### 6. Database Connection Errors

**Symptoms**: Error messages about connection, permission denied, etc.

**Solutions**:

1. **Verify Credentials**:
   - Check Supabase URL and anon key in `lib/main.dart`
   - Ensure they match your Supabase project

2. **Check Project Status**:
   - Verify Supabase project is not paused
   - Check project is within usage limits

3. **Check Network**:
   - Ensure device/emulator has internet connection
   - Check firewall isn't blocking Supabase

### 7. Foreign Key Errors

**Symptoms**: Errors about foreign key relationships

**Solutions**:

1. **Simplify Queries**:
   - The code now uses simplified queries without complex joins
   - If you see foreign key errors, the code will fall back to basic queries

2. **Check Relationships**:
   - Ensure foreign keys are properly set up in database
   - Verify `vendor_id` in events matches a user ID in profiles

## Quick Diagnostic Steps

1. **Check Supabase Connection**:
   ```dart
   // Add this to test connection
   final test = await supabase.from('events').select('count').limit(1);
   print('Connection test: $test');
   ```

2. **Check User Authentication**:
   ```dart
   final user = supabase.auth.currentUser;
   print('Current user: ${user?.id}');
   ```

3. **Check Database Tables**:
   - Go to Supabase Dashboard > Table Editor
   - Verify all tables exist and have data

4. **Check RLS Policies**:
   - Go to Supabase Dashboard > Authentication > Policies
   - Verify policies allow necessary operations

## Getting Help

If issues persist:

1. Check Flutter console for detailed error messages
2. Check Supabase logs in dashboard
3. Verify all setup steps in `SETUP_INSTRUCTIONS.md`
4. Ensure SQL schema was run completely
5. Test database queries directly in Supabase SQL Editor

## Quick Fixes

**Reset Everything**:
1. Delete app data/cache
2. Re-run SQL schema
3. Re-login
4. Create test data

**Test with Sample Data**:
```sql
-- Add test profile
INSERT INTO profiles (id, role, is_approved)
VALUES ('test-user-id', 'client', true);

-- Add test event
INSERT INTO events (title, description, venue, price, vendor_id, event_type)
VALUES ('Test Wedding', 'Beautiful wedding', 'Venue Name', 5000, 'test-user-id', 'Wedding');

-- Add test FAQ
INSERT INTO faq (question, answer)
VALUES ('Test Question?', 'Test Answer');
```

