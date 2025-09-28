-- TownConnect Database Schema
-- This script creates the initial database schema for the TownConnect app

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User Types Enum
CREATE TYPE user_type AS ENUM (
    'resident',
    'business_owner',
    'event_organizer',
    'community_leader',
    'admin'
);

-- Social Provider Enum
CREATE TYPE social_provider AS ENUM (
    'apple',
    'google',
    'facebook',
    'email'
);

-- RSVP Status Enum
CREATE TYPE rsvp_status AS ENUM (
    'pending',
    'accepted',
    'declined'
);

-- Users table (extends auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    bio TEXT DEFAULT '',
    interests TEXT[] DEFAULT '{}',
    avatar_data BYTEA,
    
    -- Authentication fields
    email VARCHAR(255),
    phone_number VARCHAR(20),
    user_type user_type DEFAULT 'resident',
    social_provider social_provider DEFAULT 'email',
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_onboarding_complete BOOLEAN DEFAULT FALSE,
    
    -- Location and community
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    
    -- Privacy settings
    is_profile_public BOOLEAN DEFAULT TRUE,
    show_email BOOLEAN DEFAULT FALSE,
    show_phone BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Events table
CREATE TABLE public.events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    details TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    host_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    attendee_ids UUID[] DEFAULT '{}',
    cover_image_data BYTEA,
    
    -- Event metadata
    max_attendees INTEGER,
    is_public BOOLEAN DEFAULT TRUE,
    requires_approval BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Follows table (user relationships)
CREATE TABLE public.follows (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    follower_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    following_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate follows and self-follows
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Invites table
CREATE TABLE public.invites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    inviter_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    invitee_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status rsvp_status DEFAULT 'pending',
    message TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate invites
    UNIQUE(event_id, invitee_id)
);

-- Event Attendance table (separate from attendee_ids for better querying)
CREATE TABLE public.event_attendance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status rsvp_status DEFAULT 'accepted',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate attendance records
    UNIQUE(event_id, user_id)
);

-- Indexes for better performance
CREATE INDEX idx_users_username ON public.users(username);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_user_type ON public.users(user_type);
CREATE INDEX idx_users_city_state ON public.users(city, state);
CREATE INDEX idx_users_created_at ON public.users(created_at);

CREATE INDEX idx_events_host_id ON public.events(host_id);
CREATE INDEX idx_events_start_date ON public.events(start_date);
CREATE INDEX idx_events_location ON public.events(location);
CREATE INDEX idx_events_is_public ON public.events(is_public);

CREATE INDEX idx_follows_follower_id ON public.follows(follower_id);
CREATE INDEX idx_follows_following_id ON public.follows(following_id);

CREATE INDEX idx_invites_event_id ON public.invites(event_id);
CREATE INDEX idx_invites_invitee_id ON public.invites(invitee_id);
CREATE INDEX idx_invites_status ON public.invites(status);

CREATE INDEX idx_event_attendance_event_id ON public.event_attendance(event_id);
CREATE INDEX idx_event_attendance_user_id ON public.event_attendance(user_id);

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at 
    BEFORE UPDATE ON public.events 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invites_updated_at 
    BEFORE UPDATE ON public.invites 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_attendance_updated_at 
    BEFORE UPDATE ON public.event_attendance 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();