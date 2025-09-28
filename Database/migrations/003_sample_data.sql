-- Sample Data for TownConnect (for testing purposes)
-- This script creates sample users and events to test the application

-- Note: In a real application, users would be created through the authentication flow
-- This is just for testing purposes

-- Sample Users (these would normally be created via auth signup)
-- You'll need to create these users through your authentication system first

-- Sample Events (can be added after users are created)
INSERT INTO public.events (
    id,
    title,
    details,
    location,
    start_date,
    end_date,
    host_id,
    is_public,
    max_attendees
) VALUES 
(
    uuid_generate_v4(),
    'Community Cleanup Day',
    'Join us for our monthly community cleanup! We''ll provide all the supplies - just bring yourself and a positive attitude. Meet at the community center.',
    'Community Center, Main Street',
    '2024-01-15 09:00:00+00',
    '2024-01-15 12:00:00+00',
    (SELECT id FROM public.users WHERE user_type = 'community_leader' LIMIT 1),
    true,
    50
),
(
    uuid_generate_v4(),
    'Coffee & Conversation',
    'Weekly coffee meetup for neighbors to connect and chat. All are welcome! We''ll be discussing upcoming community initiatives.',
    'Local Coffee Shop, Oak Avenue',
    '2024-01-18 08:30:00+00',
    '2024-01-18 10:00:00+00',
    (SELECT id FROM public.users WHERE user_type = 'resident' LIMIT 1),
    true,
    20
),
(
    uuid_generate_v4(),
    'Small Business Networking',
    'Monthly networking event for local business owners. Share ideas, collaborate, and support each other''s ventures.',
    'Business District Community Hall',
    '2024-01-20 18:00:00+00',
    '2024-01-20 20:30:00+00',
    (SELECT id FROM public.users WHERE user_type = 'business_owner' LIMIT 1),
    true,
    30
),
(
    uuid_generate_v4(),
    'Family Movie Night',
    'Join us for a family-friendly outdoor movie screening under the stars. Bring blankets and snacks!',
    'Town Park Amphitheater',
    '2024-01-22 19:00:00+00',
    '2024-01-22 22:00:00+00',
    (SELECT id FROM public.users WHERE user_type = 'event_organizer' LIMIT 1),
    true,
    100
),
(
    uuid_generate_v4(),
    'Book Club Meeting',
    'This month we''re discussing "The Seven Husbands of Evelyn Hugo". New members welcome!',
    'Public Library, Meeting Room B',
    '2024-01-25 19:00:00+00',
    '2024-01-25 20:30:00+00',
    (SELECT id FROM public.users WHERE user_type = 'resident' LIMIT 1),
    true,
    15
);

-- Create some sample follows (after users exist)
-- This would normally happen through the app interface

-- Sample interests that could be used for user profiles
-- These match the interests defined in the ProfileCompletionView
COMMENT ON TABLE public.users IS 'Available interests: Community Events, Local Business, Sports, Arts & Culture, Food & Dining, Health & Wellness, Education, Environment, Technology, Music, Family Activities, Volunteering';

-- Create a sample admin user function that can be called after auth users are created
CREATE OR REPLACE FUNCTION create_sample_admin_user(admin_email TEXT)
RETURNS void AS $$
DECLARE
    admin_id UUID;
BEGIN
    -- Get the auth user ID by email
    SELECT id INTO admin_id FROM auth.users WHERE email = admin_email;
    
    IF admin_id IS NOT NULL THEN
        -- Update the user to be an admin
        UPDATE public.users 
        SET 
            user_type = 'admin',
            username = 'admin',
            full_name = 'TownConnect Administrator',
            bio = 'Community administrator for TownConnect',
            city = 'Demo City',
            state = 'Demo State',
            is_onboarding_complete = true,
            interests = ARRAY['Community Events', 'Local Business', 'Volunteering']
        WHERE id = admin_id;
        
        RAISE NOTICE 'Admin user created successfully for %', admin_email;
    ELSE
        RAISE NOTICE 'No auth user found with email %', admin_email;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Usage instructions for the sample data
COMMENT ON FUNCTION create_sample_admin_user IS 'Call this function after creating an admin user through auth: SELECT create_sample_admin_user(''admin@example.com'');';