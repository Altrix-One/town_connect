-- TownConnect Enhanced Database Schema - CORRECTED VERSION
-- Run this SQL to create all necessary tables and functions for social features

-- Note: This schema uses snake_case for database columns which is PostgreSQL convention
-- The Swift models use camelCase which will be handled by the API layer

-- 1. Update existing users table with new social fields
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS neighborhood TEXT,
ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS event_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS photo_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS badge TEXT,
ADD COLUMN IF NOT EXISTS cover_image_data BYTEA,
ADD COLUMN IF NOT EXISTS cover_image_url TEXT,
ADD COLUMN IF NOT EXISTS theme TEXT,
ADD COLUMN IF NOT EXISTS website TEXT,
ADD COLUMN IF NOT EXISTS social_links JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS show_location BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS allow_tagging BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS allow_event_invites BOOLEAN DEFAULT true;

-- 2. Update existing events table with new social fields
ALTER TABLE events 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'community',
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'upcoming',
ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS max_attendees INTEGER,
ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS photo_ids UUID[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS like_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS comment_count INTEGER DEFAULT 0;

-- 3. Create event_photos table
CREATE TABLE IF NOT EXISTS event_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    caption TEXT DEFAULT '',
    image_url TEXT,
    image_data BYTEA,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    photo_id UUID REFERENCES event_photos(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    reply_to_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT comment_target_check CHECK (
        (event_id IS NOT NULL AND photo_id IS NULL) OR 
        (event_id IS NULL AND photo_id IS NOT NULL)
    )
);

-- 5. Create reactions table
CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    photo_id UUID REFERENCES event_photos(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('like', 'love', 'laugh', 'wow', 'sad', 'angry')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT reaction_target_check CHECK (
        (event_id IS NOT NULL AND photo_id IS NULL AND comment_id IS NULL) OR 
        (event_id IS NULL AND photo_id IS NOT NULL AND comment_id IS NULL) OR
        (event_id IS NULL AND photo_id IS NULL AND comment_id IS NOT NULL)
    ),
    UNIQUE(user_id, event_id, photo_id, comment_id)
);

-- 6. Create follows table for user relationships
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

-- 7. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('follow', 'like', 'comment', 'event_invite', 'event_update', 'photo_tag')),
    title TEXT NOT NULL,
    message TEXT,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    photo_id UUID REFERENCES event_photos(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Update invites table with additional fields if they don't exist
-- Note: Using snake_case to match database conventions
DO $$ 
BEGIN
    -- Check if columns exist before adding them
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invites' AND column_name = 'message') THEN
        ALTER TABLE invites ADD COLUMN message TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invites' AND column_name = 'created_at') THEN
        ALTER TABLE invites ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invites' AND column_name = 'updated_at') THEN
        ALTER TABLE invites ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_event_photos_event_id ON event_photos(event_id);
CREATE INDEX IF NOT EXISTS idx_event_photos_user_id ON event_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_event_id ON comments(event_id);
CREATE INDEX IF NOT EXISTS idx_comments_photo_id ON comments(photo_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_reactions_user_id ON reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_reactions_event_id ON reactions(event_id);
CREATE INDEX IF NOT EXISTS idx_reactions_photo_id ON reactions(photo_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Create updated_at triggers for tables that need them
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables (drop first to avoid conflicts)
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_events_updated_at ON events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_event_photos_updated_at ON event_photos;
CREATE TRIGGER update_event_photos_updated_at BEFORE UPDATE ON event_photos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_invites_updated_at ON invites;
CREATE TRIGGER update_invites_updated_at BEFORE UPDATE ON invites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security on new tables
ALTER TABLE event_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies - simplified and corrected
-- Event photos are viewable by everyone for public events, or event attendees
DROP POLICY IF EXISTS "Event photos are viewable by attendees" ON event_photos;
CREATE POLICY "Event photos are viewable by attendees" ON event_photos
    FOR SELECT USING (
        is_visible = true AND (
            event_id IN (SELECT id FROM events WHERE is_public = true) OR
            user_id = auth.uid()
        )
    );

-- Users can insert their own event photos
DROP POLICY IF EXISTS "Users can insert their own event photos" ON event_photos;
CREATE POLICY "Users can insert their own event photos" ON event_photos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own event photos
DROP POLICY IF EXISTS "Users can update their own event photos" ON event_photos;
CREATE POLICY "Users can update their own event photos" ON event_photos
    FOR UPDATE USING (auth.uid() = user_id);

-- Comments are viewable if the related content is viewable
DROP POLICY IF EXISTS "Comments are viewable for accessible content" ON comments;
CREATE POLICY "Comments are viewable for accessible content" ON comments
    FOR SELECT USING (
        (event_id IS NOT NULL AND event_id IN (
            SELECT id FROM events WHERE is_public = true
        )) OR
        (photo_id IS NOT NULL AND photo_id IN (
            SELECT id FROM event_photos WHERE is_visible = true
        ))
    );

-- Users can insert comments
DROP POLICY IF EXISTS "Users can insert comments" ON comments;
CREATE POLICY "Users can insert comments" ON comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own comments
DROP POLICY IF EXISTS "Users can update their own comments" ON comments;
CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id);

-- Reactions are viewable by everyone
DROP POLICY IF EXISTS "Reactions are viewable by everyone" ON reactions;
CREATE POLICY "Reactions are viewable by everyone" ON reactions
    FOR SELECT USING (true);

-- Users can manage their own reactions
DROP POLICY IF EXISTS "Users can manage their own reactions" ON reactions;
CREATE POLICY "Users can manage their own reactions" ON reactions
    FOR ALL USING (auth.uid() = user_id);

-- Follows are viewable by everyone
DROP POLICY IF EXISTS "Follows are viewable by everyone" ON follows;
CREATE POLICY "Follows are viewable by everyone" ON follows
    FOR SELECT USING (true);

-- Users can manage follows they initiate
DROP POLICY IF EXISTS "Users can manage their own follows" ON follows;
CREATE POLICY "Users can manage their own follows" ON follows
    FOR ALL USING (auth.uid() = follower_id);

-- Notifications are only viewable by the recipient
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);