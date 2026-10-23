# EventSphere Setup Instructions

## Overview
EventSphere is a full-featured event management app that allows users to browse events by type (Wedding, Party, Birthday, Seminar), select services, compare providers, and make bookings. Providers receive notifications when bookings are confirmed.

## Prerequisites
- Flutter SDK (>=2.18.0)
- Supabase account
- Android Studio / VS Code with Flutter extensions

## Step 1: Supabase Setup

### 1.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and anon key from Settings > API

### 1.2 Update Supabase Credentials
Update the Supabase URL and anon key in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: "YOUR_SUPABASE_URL",
  anonKey: "YOUR_SUPABASE_ANON_KEY",
);
```

### 1.3 Run Database Schema
1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy and paste the entire contents of `SUPABASE_SCHEMA.sql`
4. Run the SQL script
5. Verify all tables are created (check Table Editor)

### 1.4 Create Storage Bucket
1. Go to Storage in Supabase dashboard
2. Create a new bucket named `event-images`
3. Set it as **Public**
4. Set file size limit to 5MB
5. Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`

### 1.5 Update Storage Policies
The SQL schema includes storage policies, but verify they're applied:
- Anyone can view event images
- Authenticated users can upload
- Users can update/delete their own images

## Step 2: Flutter Setup

### 2.1 Install Dependencies
```bash
flutter pub get
```

### 2.2 Verify Dependencies
Check `pubspec.yaml` includes:
- `supabase_flutter: ^1.3.0`
- `image_picker: ^0.8.7+4`
- `intl: ^0.18.0`

### 2.3 Run the App
```bash
flutter run
```

## Step 3: Initial Data Setup

### 3.1 Create Admin User
1. Sign up a user through the app
2. In Supabase Dashboard > Table Editor > profiles
3. Find your user and set:
   - `role` = `'admin'`
   - `is_approved` = `true`

### 3.2 Create Sample Services (Optional)
The SQL schema includes sample services, but you can add more:
- Go to Table Editor > services
- Add services like: Catering, Decoration, Photography, etc.

### 3.3 Link Services to Event Types
- Go to Table Editor > event_services
- Link services to event types (Wedding, Party, Birthday, Seminar)

## Step 4: Testing the App

### 4.1 User Flow
1. **Register** as a User or Provider
2. **Login** with your credentials
3. **Browse Events** by type (Wedding, Party, Birthday, Seminar)
4. **Select Services** for an event type
5. **Compare Providers** by rating and price
6. **Confirm Booking** - Provider receives notification

### 4.2 Provider Flow
1. **Register** as Provider
2. **Wait for Admin Approval** (if not auto-approved)
3. **Create Events** with event type
4. **View Notifications** when bookings are confirmed
5. **Manage Events** from vendor dashboard

### 4.3 Admin Flow
1. **Login** as admin
2. **Approve Vendors** from admin panel
3. **Manage FAQ** entries
4. **View All Events and Bookings**

## Step 5: Database Structure

### Key Tables
- **profiles**: User profiles with roles (client, vendor, admin)
- **events**: Events created by vendors
- **services**: Available services (Catering, Decoration, etc.)
- **event_services**: Links services to event types
- **provider_services**: Links providers to services they offer
- **bookings**: User bookings
- **booking_services**: Selected services for each booking
- **reviews**: User reviews for events
- **notifications**: Notifications for users (especially vendors)
- **faq**: FAQ entries

### Important Relationships
- Events belong to vendors (vendor_id)
- Bookings belong to users and events
- Provider services link providers to services
- Notifications are sent to vendors when bookings are confirmed

## Step 6: Troubleshooting

### Common Issues

1. **Import Errors**
   - Ensure all import paths use correct case: `Screens`, `Services`, `Widgets`

2. **Supabase Connection Errors**
   - Verify URL and anon key in `main.dart`
   - Check Supabase project is active
   - Verify RLS policies allow your operations

3. **Storage Upload Errors**
   - Ensure `event-images` bucket exists and is public
   - Check storage policies are applied
   - Verify file size limits

4. **Database Errors**
   - Run the SQL schema again
   - Check all foreign key relationships
   - Verify RLS policies

5. **Notification Not Working**
   - Check notifications table exists
   - Verify RLS policies allow insert/select
   - Check user_id matches in notifications

## Step 7: Customization

### Adding New Event Types
1. Update `eventTypes` list in `home_screen.dart`
2. Add event type to `vendor_add_event_screen.dart`
3. Add services for new event type in `event_services` table

### Adding New Services
1. Insert into `services` table
2. Link to event types in `event_services` table
3. Providers can then offer these services via `provider_services`

### Modifying UI
- Colors: Update `ThemeData` in `main.dart`
- Layouts: Modify individual screen files
- Widgets: Update files in `lib/Widgets/`

## Step 8: Production Deployment

### Before Deploying
1. **Update Supabase URL/Key** - Use production credentials
2. **Review RLS Policies** - Ensure security is appropriate
3. **Test All Flows** - User, Provider, Admin
4. **Set Up Error Monitoring** - Consider Sentry or similar
5. **Configure App Icons** - Update in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/`

### Build for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Support

For issues or questions:
1. Check the SQL schema comments
2. Review Supabase logs in dashboard
3. Check Flutter console for errors
4. Verify all dependencies are up to date

## Notes

- The app uses Row Level Security (RLS) for data protection
- All images are stored in Supabase Storage
- Notifications are stored in database (consider push notifications for production)
- Review stats are calculated via SQL function
- Profile creation is automated via database trigger

