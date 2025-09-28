import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var fullName: String
    var bio: String
    var interests: [String]
    var avatarData: Data? // simple local storage
    
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
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?
    
    // Privacy settings
    var isProfilePublic: Bool
    var showEmail: Bool
    var showPhone: Bool
    
    init(
        id: UUID = UUID(),
        username: String,
        fullName: String,
        bio: String = "",
        interests: [String] = [],
        avatarData: Data? = nil,
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
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastLoginAt: Date? = nil,
        isProfilePublic: Bool = true,
        showEmail: Bool = false,
        showPhone: Bool = false
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.interests = interests
        self.avatarData = avatarData
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.isProfilePublic = isProfilePublic
        self.showEmail = showEmail
        self.showPhone = showPhone
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
}
