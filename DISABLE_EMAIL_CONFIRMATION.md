# How to Disable Email Confirmation in Supabase

## Problem
"Email not confirmed" error prevents login.

## Solution: Disable Email Confirmation

### Step 1: Go to Supabase Dashboard
1. Open your Supabase project
2. Go to **Authentication** → **Settings**

### Step 2: Disable Email Confirmation
1. Find **"Enable email confirmations"** setting
2. **Toggle it OFF** (disable)
3. Click **Save**

### Step 3: Test Login
1. Try logging in again
2. Should work without email confirmation

## Alternative: Handle Email Confirmation in Code

If you want to keep email confirmation enabled, you can:

1. **Send confirmation email** after registration
2. **Resend confirmation** if user needs it
3. **Show message** telling user to check email

But for development/testing, it's easier to disable it.

## For Production

In production, you should:
1. Keep email confirmation enabled
2. Send confirmation emails
3. Handle "email not confirmed" errors gracefully
4. Provide "Resend confirmation email" option

## Quick Fix

**For now, just disable email confirmation in Supabase Dashboard to test the app.**

