-- Sample Data for EventSphere
-- Run this AFTER running SUPABASE_SCHEMA.sql
-- This will populate your database with test events, FAQs, and services

-- ============================================
-- 1. SAMPLE EVENTS (Wedding, Party, Birthday, Seminar)
-- ============================================

-- Note: Replace 'YOUR_VENDOR_USER_ID' with an actual user ID from auth.users table
-- You can get this by registering a vendor account first, then checking auth.users table

-- Wedding Events
INSERT INTO events (title, description, venue, price, vendor_id, event_type, image)
VALUES 
  ('Luxury Wedding Package', 'Complete wedding package including venue, catering, decoration, photography, and music. Perfect for your special day.', 'Grand Ballroom', 15000.00, (SELECT id FROM auth.users LIMIT 1), 'Wedding', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'),
  ('Premium Wedding Celebration', 'Elegant wedding celebration with premium services. Includes floral arrangements, lighting, and sound system.', 'Royal Palace', 25000.00, (SELECT id FROM auth.users LIMIT 1), 'Wedding', 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800'),
  ('Intimate Wedding Package', 'Beautiful intimate wedding for smaller gatherings. Includes all essential services at an affordable price.', 'Garden Venue', 8000.00, (SELECT id FROM auth.users LIMIT 1), 'Wedding', 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800')
ON CONFLICT DO NOTHING;

-- Party Events
INSERT INTO events (title, description, venue, price, vendor_id, event_type, image)
VALUES 
  ('Birthday Party Package', 'Fun-filled birthday party with decorations, catering, music, and entertainment. Perfect for all ages!', 'Party Hall', 3000.00, (SELECT id FROM auth.users LIMIT 1), 'Party', 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'),
  ('Corporate Party Package', 'Professional corporate event package with catering, sound system, and networking setup.', 'Conference Center', 5000.00, (SELECT id FROM auth.users LIMIT 1), 'Party', 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800'),
  ('Graduation Party Celebration', 'Celebrate your graduation in style! Includes decorations, food, music, and photography.', 'Event Space', 4000.00, (SELECT id FROM auth.users LIMIT 1), 'Party', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800')
ON CONFLICT DO NOTHING;

-- Birthday Events
INSERT INTO events (title, description, venue, price, vendor_id, event_type, image)
VALUES 
  ('Kids Birthday Party', 'Magical birthday party for kids with themes, decorations, games, and party favors. Make their day special!', 'Party Venue', 2000.00, (SELECT id FROM auth.users LIMIT 1), 'Birthday', 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800'),
  ('Adult Birthday Bash', 'Elegant birthday celebration for adults. Includes premium catering, bar service, and entertainment.', 'Lounge', 4500.00, (SELECT id FROM auth.users LIMIT 1), 'Birthday', 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800'),
  ('Surprise Birthday Party', 'Plan the perfect surprise party! Includes decorations, catering, photography, and coordination services.', 'Private Venue', 3500.00, (SELECT id FROM auth.users LIMIT 1), 'Birthday', 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800')
ON CONFLICT DO NOTHING;

-- Seminar Events
INSERT INTO events (title, description, venue, price, vendor_id, event_type, image)
VALUES 
  ('Business Seminar Package', 'Professional seminar setup with venue, sound system, projection, and catering. Perfect for business events.', 'Conference Hall', 6000.00, (SELECT id FROM auth.users LIMIT 1), 'Seminar', 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800'),
  ('Educational Workshop', 'Complete workshop package with venue, equipment, and refreshments. Ideal for training sessions.', 'Training Center', 4000.00, (SELECT id FROM auth.users LIMIT 1), 'Seminar', 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800'),
  ('Tech Conference Package', 'Modern tech conference setup with high-speed internet, AV equipment, and premium catering.', 'Tech Hub', 8000.00, (SELECT id FROM auth.users LIMIT 1), 'Seminar', 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800')
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. SAMPLE FAQ ENTRIES
-- ============================================

INSERT INTO faq (question, answer)
VALUES 
  ('How do I book an event?', 'Browse events by category (Wedding, Party, Birthday, Seminar), select an event, choose services you need, compare providers, and confirm your booking.'),
  ('Can I customize my event package?', 'Yes! When you select an event, you can choose specific services and compare different providers based on ratings and prices.'),
  ('How are providers rated?', 'Providers are rated based on reviews from previous customers. Ratings are calculated from 1 to 5 stars based on service quality.'),
  ('What payment methods do you accept?', 'Currently, we support various payment methods. Payment details will be discussed after booking confirmation.'),
  ('Can I cancel my booking?', 'Yes, you can cancel your booking. Please contact support or the provider directly for cancellation policies.'),
  ('How far in advance should I book?', 'We recommend booking at least 2-4 weeks in advance to ensure availability, especially for popular dates and venues.'),
  ('Do you provide catering services?', 'Yes! Many of our event packages include catering. You can select catering as one of the services when booking.'),
  ('What if I need additional services?', 'You can add additional services during the booking process. Simply select all the services you need and compare providers.'),
  ('How do I contact a provider?', 'After booking, you will receive provider contact information. You can also view provider details in the booking confirmation.'),
  ('Is there a refund policy?', 'Refund policies vary by provider. Please check the terms and conditions when booking or contact the provider directly.')
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. SAMPLE SERVICES (if not already added)
-- ============================================

-- These should already exist from SUPABASE_SCHEMA.sql, but adding here for completeness
INSERT INTO services (name, description, category)
VALUES 
  ('Catering', 'Food and beverage services for your event', 'catering'),
  ('Decoration', 'Event decoration and setup services', 'decoration'),
  ('Photography', 'Professional photography services', 'photography'),
  ('Music & DJ', 'Music and entertainment services', 'entertainment'),
  ('Venue', 'Event venue rental', 'venue'),
  ('Floral Arrangements', 'Flowers and centerpieces', 'decoration'),
  ('Lighting', 'Event lighting setup', 'decoration'),
  ('Sound System', 'Audio equipment rental', 'entertainment')
ON CONFLICT DO NOTHING;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Replace (SELECT id FROM auth.users LIMIT 1) with actual user IDs
--    OR create vendor accounts first, then update vendor_id manually
-- 2. Images use Unsplash URLs - these are placeholder images
-- 3. Prices are in your currency (adjust as needed)
-- 4. You can modify descriptions, venues, and prices as needed
-- 5. To add more events, copy the INSERT statements and modify values

-- ============================================
-- QUICK FIX: If you get foreign key errors
-- ============================================
-- First, create a vendor profile:
-- 1. Register a vendor account in the app
-- 2. Get the user ID from auth.users table
-- 3. Update profiles table: UPDATE profiles SET role='vendor', is_approved=true WHERE id='USER_ID';
-- 4. Then run this script again, or manually set vendor_id in events

