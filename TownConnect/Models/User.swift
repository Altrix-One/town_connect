import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var fullName: String
    var bio: String
    var interests: [String]
    var avatarData: Data? // simple local storage
    var avatarUrl: String? // Supabase storage URL
    
    // Authentication fields
    var email: String?
    var phoneNumber: String?
    var userType: UserType
    var socialProvider: SocialProvider?
    var isEmailVerified: Bool
    var isOnboardingComplete: Bool
    
    // Location and community
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var neighborhood: String?
    
    // Social features
    var followerCount: Int
    var followingCount: Int
    var eventCount: Int
    var photoCount: Int
    var isVerified: Bool
    var badge: String? // Special achievements or roles
    
    // Profile customization
    var coverImageData: Data?
    var coverImageUrl: String?
    var theme: String? // User's preferred color theme
    var website: String?
    var socialLinks: [String: String] // Social media links
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?
    
    // Privacy settings
    var isProfilePublic: Bool
    var showEmail: Bool
    var showPhone: Bool
    var showLocation: Bool
    var allowTagging: Bool
    var allowEventInvites: Bool
    
    init(
        id: UUID = UUID(),
        username: String,
        fullName: String,
        bio: String = "",
        interests: [String] = [],
        avatarData: Data? = nil,
        avatarUrl: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        userType: UserType = .resident,
        socialProvider: SocialProvider? = nil,
        isEmailVerified: Bool = false,
        isOnboardingComplete: Bool = false,
        address: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zipCode: String? = nil,
        neighborhood: String? = nil,
        followerCount: Int = 0,
        followingCount: Int = 0,
        eventCount: Int = 0,
        photoCount: Int = 0,
        isVerified: Bool = false,
        badge: String? = nil,
        coverImageData: Data? = nil,
        coverImageUrl: String? = nil,
        theme: String? = nil,
        website: String? = nil,
        socialLinks: [String: String] = [:],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastLoginAt: Date? = nil,
        isProfilePublic: Bool = true,
        showEmail: Bool = false,
        showPhone: Bool = false,
        showLocation: Bool = true,
        allowTagging: Bool = true,
        allowEventInvites: Bool = true
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.interests = interests
        self.avatarData = avatarData
        self.avatarUrl = avatarUrl
        self.email = email
        self.phoneNumber = phoneNumber
        self.userType = userType
        self.socialProvider = socialProvider
        self.isEmailVerified = isEmailVerified
        self.isOnboardingComplete = isOnboardingComplete
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.neighborhood = neighborhood
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.eventCount = eventCount
        self.photoCount = photoCount
        self.isVerified = isVerified
        self.badge = badge
        self.coverImageData = coverImageData
        self.coverImageUrl = coverImageUrl
        self.theme = theme
        self.website = website
        self.socialLinks = socialLinks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.isProfilePublic = isProfilePublic
        self.showEmail = showEmail
        self.showPhone = showPhone
        self.showLocation = showLocation
        self.allowTagging = allowTagging
        self.allowEventInvites = allowEventInvites
    }
    
    // Helper methods
    var permissions: Set<Permission> {
        return PermissionSet.permissions(for: userType)
    }
    
    func hasPermission(_ permission: Permission) -> Bool {
        return permissions.contains(permission)
    }
    
    var displayLocation: String? {
        guard let city = city else { return nil }
        if let state = state {
            return "\(city), \(state)"
        }
        return city
    }
    
    // MARK: - Codable Keys
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case bio
        case interests
        case avatarData = "avatar_data"
        case avatarUrl = "avatar_url"
        case email
        case phoneNumber = "phone_number"
        case userType = "user_type"
        case socialProvider = "social_provider"
        case isEmailVerified = "is_email_verified"
        case isOnboardingComplete = "is_onboarding_complete"
        case address
        case city
        case state
        case zipCode = "zip_code"
        case neighborhood
        case followerCount = "follower_count"
        case followingCount = "following_count"
        case eventCount = "event_count"
        case photoCount = "photo_count"
        case isVerified = "is_verified"
        case badge
        case coverImageData = "cover_image_data"
        case coverImageUrl = "cover_image_url"
        case theme
        case website
        case socialLinks = "social_links"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLoginAt = "last_login_at"
        case isProfilePublic = "is_profile_public"
        case showEmail = "show_email"
        case showPhone = "show_phone"
        case showLocation = "show_location"
        case allowTagging = "allow_tagging"
        case allowEventInvites = "allow_event_invites"
    }
}
