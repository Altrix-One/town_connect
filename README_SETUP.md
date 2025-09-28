# TownConnect Setup Instructions

This guide will help you set up the TownConnect iOS app with Supabase authentication and database.

## Database Setup

### 1. Execute Database Migrations

Run the SQL migration files in your Supabase project in the following order:

#### Step 1: Create the Schema
Copy and paste the contents of `Database/migrations/001_initial_schema.sql` into your Supabase SQL editor and run it.

This creates:
- User types and enums
- Core tables (users, events, follows, invites, event_attendance)
- Indexes for performance
- Triggers for timestamp updates

#### Step 2: Set Up Security
Copy and paste the contents of `Database/migrations/002_rls_policies.sql` into your Supabase SQL editor and run it.

This creates:
- Row Level Security (RLS) policies
- User registration triggers
- Login tracking

#### Step 3: Add Sample Data (Optional)
Copy and paste the contents of `Database/migrations/003_sample_data.sql` into your Supabase SQL editor and run it.

This creates sample events and utility functions for testing.

### 2. Authentication Configuration

Your Supabase project is already configured with the correct credentials:
- **Project URL**: `https://silgkbzohsxolcwqzadc.supabase.co`
- **Anon Key**: Already set in the code

### 3. Enable Authentication Providers

In your Supabase dashboard:

1. Go to **Authentication** > **Providers**
2. Configure the providers you want to use:
   - **Email**: Already enabled by default
   - **Apple**: Follow Supabase's Apple Sign-In guide
   - **Google**: Follow Supabase's Google Sign-In guide
   - **Facebook**: Follow Supabase's Facebook Login guide

## App Features

### User Types & Permissions

The app supports 5 user types with different capabilities:

1. **Resident** - Basic community member
   - View and join events
   - Create personal events
   - Follow other users
   - Edit own profile

2. **Business Owner** - Local business representative
   - All resident permissions
   - Promote events
   - Access basic analytics

3. **Event Organizer** - Community event coordinator
   - All business owner permissions
   - Advanced event management

4. **Community Leader** - Trusted community member
   - All event organizer permissions
   - Moderate content
   - Edit community events

5. **Admin** - Full system administrator
   - All permissions
   - Manage users
   - System administration

### Authentication Flow

1. **Login/Registration** - Users can sign up with email or social providers
2. **User Type Selection** - New users choose their community role
3. **Profile Completion** - Users add their details and interests
4. **Onboarding Complete** - Users can access the full app

### Core Functionality

- **Home Feed**: See events from followed users and community
- **Explore**: Search for users and events
- **Events**: Manage your events and invitations
- **Profile**: View and edit your profile

## Development

### Building the App

1. Make sure you have Xcode 15+ installed
2. Open the project:
   ```bash
   open TownConnect.xcodeproj
   ```
3. Build and run on a simulator:
   ```bash
   xcodebuild -project TownConnect.xcodeproj \
     -scheme TownConnect \
     -configuration Debug \
     -destination 'platform=iOS Simulator,name=iPhone 15' \
     build
   ```

### Testing

Run the test suite:
```bash
xcodebuild -project TownConnect.xcodeproj \
  -scheme TownConnect \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

### Key Files

- **Authentication**: 
  - `Services/AuthService.swift` - Main authentication logic
  - `Services/SupabaseService.swift` - Database operations
  - `Views/Auth/` - Login, registration, and onboarding screens

- **User Management**:
  - `Models/UserTypes.swift` - User roles and permissions
  - `Stores/UserStore.swift` - User data management

- **Events**:
  - `Stores/EventStore.swift` - Event data management
  - `Views/Events/` - Event-related screens

## Next Steps

1. **Set up your database** by running the migration scripts
2. **Test user registration** by creating a new account
3. **Create sample users** with different roles to test permissions
4. **Configure social login** providers if needed
5. **Customize the app** branding and features for your community

## Support

If you encounter any issues:
1. Check the Supabase logs for database errors
2. Review the Xcode console for client-side errors
3. Ensure all database migrations have been run successfully
4. Verify your Supabase project settings match the configuration

The authentication system is now fully integrated with real-time database operations and proper security through Row Level Security policies.