-- EventSphere Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'client', -- 'client', 'vendor', 'admin'
  is_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. EVENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  venue TEXT,
  event_time TIMESTAMPTZ,
  price NUMERIC(10, 2) NOT NULL DEFAULT 0,
  image TEXT,
  vendor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL, -- 'Wedding', 'Party', 'Birthday', 'Seminar'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policies for events
CREATE POLICY "Anyone can view events"
  ON events FOR SELECT
  USING (true);

CREATE POLICY "Vendors can create their own events"
  ON events FOR INSERT
  WITH CHECK (
    auth.uid() = vendor_id AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'vendor' AND is_approved = true)
  );

CREATE POLICY "Vendors can update their own events"
  ON events FOR UPDATE
  USING (auth.uid() = vendor_id);

CREATE POLICY "Vendors can delete their own events"
  ON events FOR DELETE
  USING (auth.uid() = vendor_id);

-- ============================================
-- 3. SERVICES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT, -- 'catering', 'decoration', 'photography', 'music', etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view services"
  ON services FOR SELECT
  USING (true);

-- ============================================
-- 4. EVENT_SERVICES TABLE (Links services to event types)
-- ============================================
CREATE TABLE IF NOT EXISTS event_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL, -- 'Wedding', 'Party', 'Birthday', 'Seminar'
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  service_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_type, service_id)
);

-- Enable RLS
ALTER TABLE event_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view event services"
  ON event_services FOR SELECT
  USING (true);

-- ============================================
-- 5. PROVIDER_SERVICES TABLE (Links providers to services they offer)
-- ============================================
CREATE TABLE IF NOT EXISTS provider_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  price NUMERIC(10, 2) NOT NULL DEFAULT 0,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(provider_id, service_id, event_id)
);

-- Enable RLS
ALTER TABLE provider_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view provider services"
  ON provider_services FOR SELECT
  USING (true);

CREATE POLICY "Vendors can manage their provider services"
  ON provider_services FOR ALL
  USING (
    auth.uid() = provider_id AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'vendor' AND is_approved = true)
  );

-- ============================================
-- 6. BOOKINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'cancelled', 'completed'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Vendors can view bookings for their events"
  ON bookings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM events 
      WHERE events.id = bookings.event_id 
      AND events.vendor_id = auth.uid()
    )
  );

CREATE POLICY "Users can create bookings"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 7. BOOKING_SERVICES TABLE (Links selected services to bookings)
-- ============================================
CREATE TABLE IF NOT EXISTS booking_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(booking_id, service_id)
);

-- Enable RLS
ALTER TABLE booking_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view booking services for their bookings"
  ON booking_services FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings 
      WHERE bookings.id = booking_services.booking_id 
      AND bookings.user_id = auth.uid()
    )
  );

CREATE POLICY "Vendors can view booking services for their events"
  ON booking_services FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings 
      JOIN events ON events.id = bookings.event_id
      WHERE bookings.id = booking_services.booking_id 
      AND events.vendor_id = auth.uid()
    )
  );

-- ============================================
-- 8. REVIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- Enable RLS
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT
  USING (true);

CREATE POLICY "Users can create reviews"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 9. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- 'booking_confirmed', 'vendor_approved', etc.
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- 10. FAQ TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS faq (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE faq ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view FAQ"
  ON faq FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage FAQ"
  ON faq FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================
-- 11. FUNCTION: Get Event Review Stats
-- ============================================
CREATE OR REPLACE FUNCTION get_event_review_stats(event_id UUID)
RETURNS JSON AS $$
  SELECT json_build_object(
    'avg_rating', COALESCE(AVG(rating), 0),
    'review_count', COUNT(*)
  )
  FROM reviews
  WHERE reviews.event_id = get_event_review_stats.event_id;
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================
-- 12. TRIGGER: Create profile on user signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, is_approved)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client'),
    false
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 13. STORAGE BUCKET: event-images
-- ============================================
-- Create storage bucket (run in Supabase Dashboard > Storage)
-- Bucket name: event-images
-- Public: true
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- Storage policies
CREATE POLICY "Anyone can view event images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'event-images');

CREATE POLICY "Authenticated users can upload event images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'event-images' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can update their own images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'event-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'event-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================
-- 14. SAMPLE DATA (Optional - for testing)
-- ============================================

-- Sample Services
INSERT INTO services (name, description, category) VALUES
  ('Catering', 'Food and beverage services', 'catering'),
  ('Decoration', 'Event decoration and setup', 'decoration'),
  ('Photography', 'Professional photography services', 'photography'),
  ('Music & DJ', 'Music and entertainment', 'entertainment'),
  ('Venue', 'Event venue rental', 'venue'),
  ('Floral Arrangements', 'Flowers and centerpieces', 'decoration'),
  ('Lighting', 'Event lighting setup', 'decoration'),
  ('Sound System', 'Audio equipment rental', 'entertainment')
ON CONFLICT DO NOTHING;

-- Sample Event Services (Link services to event types)
-- Wedding services
INSERT INTO event_services (event_type, service_id, service_order) 
SELECT 'Wedding', id, row_number() OVER ()
FROM services 
WHERE name IN ('Catering', 'Decoration', 'Photography', 'Music & DJ', 'Venue', 'Floral Arrangements', 'Lighting')
ON CONFLICT DO NOTHING;

-- Party services
INSERT INTO event_services (event_type, service_id, service_order) 
SELECT 'Party', id, row_number() OVER ()
FROM services 
WHERE name IN ('Catering', 'Music & DJ', 'Decoration', 'Photography', 'Sound System')
ON CONFLICT DO NOTHING;

-- Birthday services
INSERT INTO event_services (event_type, service_id, service_order) 
SELECT 'Birthday', id, row_number() OVER ()
FROM services 
WHERE name IN ('Catering', 'Decoration', 'Photography', 'Music & DJ')
ON CONFLICT DO NOTHING;

-- Seminar services
INSERT INTO event_services (event_type, service_id, service_order) 
SELECT 'Seminar', id, row_number() OVER ()
FROM services 
WHERE name IN ('Venue', 'Sound System', 'Catering')
ON CONFLICT DO NOTHING;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Make sure to create the storage bucket 'event-images' in Supabase Dashboard
-- 2. Update the storage policies if needed based on your requirements
-- 3. The handle_new_user trigger automatically creates a profile when a user signs up
-- 4. Adjust RLS policies based on your security requirements
-- 5. You may need to manually set some users as 'admin' in the profiles table

