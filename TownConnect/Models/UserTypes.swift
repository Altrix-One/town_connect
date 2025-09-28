import Foundation

// MARK: - User Types
enum UserType: String, CaseIterable, Codable {
    case resident = "resident"
    case businessOwner = "business_owner"
    case eventOrganizer = "event_organizer"
    case communityLeader = "community_leader"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .resident:
            return "Resident"
        case .businessOwner:
            return "Business Owner"
        case .eventOrganizer:
            return "Event Organizer"
        case .communityLeader:
            return "Community Leader"
        case .admin:
            return "Administrator"
        }
    }
    
    var description: String {
        switch self {
        case .resident:
            return "Connect with neighbors and join local events"
        case .businessOwner:
            return "Promote your business and engage with the community"
        case .eventOrganizer:
            return "Create and manage community events"
        case .communityLeader:
            return "Lead community initiatives and moderate content"
        case .admin:
            return "Full system administration access"
        }
    }
}

// MARK: - Permissions
enum Permission: String, CaseIterable, Codable {
    case viewEvents = "view_events"
    case createEvents = "create_events"
    case editOwnEvents = "edit_own_events"
    case editAllEvents = "edit_all_events"
    case deleteOwnEvents = "delete_own_events"
    case deleteAllEvents = "delete_all_events"
    case viewUsers = "view_users"
    case editOwnProfile = "edit_own_profile"
    case editAllProfiles = "edit_all_profiles"
    case moderateContent = "moderate_content"
    case manageUsers = "manage_users"
    case systemAdmin = "system_admin"
    case promoteEvents = "promote_events"
    case accessAnalytics = "access_analytics"
}

// MARK: - Permission Sets
struct PermissionSet {
    static let resident: Set<Permission> = [
        .viewEvents,
        .createEvents,
        .editOwnEvents,
        .deleteOwnEvents,
        .viewUsers,
        .editOwnProfile
    ]
    
    static let businessOwner: Set<Permission> = resident.union([
        .promoteEvents,
        .accessAnalytics
    ])
    
    static let eventOrganizer: Set<Permission> = resident.union([
        .promoteEvents,
        .accessAnalytics
    ])
    
    static let communityLeader: Set<Permission> = eventOrganizer.union([
        .moderateContent,
        .editAllEvents
    ])
    
    static let admin: Set<Permission> = Set(Permission.allCases)
    
    static func permissions(for userType: UserType) -> Set<Permission> {
        switch userType {
        case .resident:
            return resident
        case .businessOwner:
            return businessOwner
        case .eventOrganizer:
            return eventOrganizer
        case .communityLeader:
            return communityLeader
        case .admin:
            return admin
        }
    }
}

// MARK: - Social Login Providers
enum SocialProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"
    case facebook = "facebook"
    case email = "email"
    
    var displayName: String {
        switch self {
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        case .facebook:
            return "Facebook"
        case .email:
            return "Email"
        }
    }
}

// MARK: - Authentication Status
enum AuthStatus: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case onboarding(User)
    case emailVerificationRequired(String) // email parameter
    case error(String)
}
