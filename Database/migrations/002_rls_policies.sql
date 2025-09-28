-- Row Level Security Policies for TownConnect
-- These policies ensure users can only access data they're authorized to see

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_attendance ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Users can read public profiles and their own profile
CREATE POLICY "Users can view public profiles" ON public.users
    FOR SELECT USING (is_profile_public = true OR auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile" ON public.users
    FOR DELETE USING (auth.uid() = id);

-- Events table policies
-- Users can view public events and events they're invited to or hosting
CREATE POLICY "Users can view public events" ON public.events
    FOR SELECT USING (
        is_public = true 
        OR host_id = auth.uid()
        OR auth.uid() = ANY(attendee_ids)
        OR EXISTS (
            SELECT 1 FROM public.invites 
            WHERE event_id = events.id AND invitee_id = auth.uid()
        )
    );

-- Users can create events
CREATE POLICY "Authenticated users can create events" ON public.events
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND host_id = auth.uid());

-- Users can update events they host
CREATE POLICY "Users can update own events" ON public.events
    FOR UPDATE USING (host_id = auth.uid());

-- Users can delete events they host
CREATE POLICY "Users can delete own events" ON public.events
    FOR DELETE USING (host_id = auth.uid());

-- Follows table policies
-- Users can view follows where they are the follower or being followed
CREATE POLICY "Users can view relevant follows" ON public.follows
    FOR SELECT USING (
        follower_id = auth.uid() 
        OR following_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = following_id AND is_profile_public = true
        )
    );

-- Users can create follows where they are the follower
CREATE POLICY "Users can follow others" ON public.follows
    FOR INSERT WITH CHECK (follower_id = auth.uid());

-- Users can delete follows where they are the follower
CREATE POLICY "Users can unfollow others" ON public.follows
    FOR DELETE USING (follower_id = auth.uid());

-- Invites table policies
-- Users can view invites where they are the inviter or invitee
CREATE POLICY "Users can view their invites" ON public.invites
    FOR SELECT USING (inviter_id = auth.uid() OR invitee_id = auth.uid());

-- Event hosts can create invites for their events
CREATE POLICY "Event hosts can create invites" ON public.invites
    FOR INSERT WITH CHECK (
        inviter_id = auth.uid() 
        AND EXISTS (
            SELECT 1 FROM public.events 
            WHERE id = event_id AND host_id = auth.uid()
        )
    );

-- Invitees can update their invite status
CREATE POLICY "Invitees can update invite status" ON public.invites
    FOR UPDATE USING (invitee_id = auth.uid());

-- Inviters can delete their invites
CREATE POLICY "Inviters can delete invites" ON public.invites
    FOR DELETE USING (inviter_id = auth.uid());

-- Event Attendance table policies
-- Users can view attendance for events they can see
CREATE POLICY "Users can view event attendance" ON public.event_attendance
    FOR SELECT USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.events 
            WHERE id = event_id AND (
                is_public = true 
                OR host_id = auth.uid()
                OR auth.uid() = ANY(attendee_ids)
            )
        )
    );

-- Users can manage their own attendance
CREATE POLICY "Users can manage own attendance" ON public.event_attendance
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Event hosts can manage attendance for their events
CREATE POLICY "Event hosts can manage attendance" ON public.event_attendance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.events 
            WHERE id = event_id AND host_id = auth.uid()
        )
    );

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, username, is_email_verified)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
        NEW.email_confirmed_at IS NOT NULL
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update user last_login_at
CREATE OR REPLACE FUNCTION public.update_user_last_login()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at THEN
        UPDATE public.users 
        SET last_login_at = NEW.last_sign_in_at
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update last_login_at on auth user update
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.update_user_last_login();