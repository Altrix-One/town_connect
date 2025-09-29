import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    
    let user: User
    @State private var userEvents: [Event] = []
    @State private var userPhotos: [EventPhoto] = []
    @State private var isFollowing = false
    @State private var isLoading = false
    @State private var selectedTab = 0 // 0: Events, 1: Photos
    
    private var currentUser: User? { userStore.currentUser }
    private var isOwnProfile: Bool { user.id == currentUser?.id }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xl) {
                // Profile Header
                ProfileHeaderView(
                    user: user,
                    isFollowing: $isFollowing,
                    isOwnProfile: isOwnProfile,
                    onFollowTap: handleFollowToggle,
                    onMessageTap: handleMessage
                )
                
                // Stats Section
                ProfileStatsView(
                    followerCount: user.followerCount,
                    followingCount: user.followingCount,
                    eventCount: user.eventCount,
                    photoCount: user.photoCount
                )
                .padding(.horizontal, DesignSystem.Spacing.xl)
                
                // Bio and Details
                if !user.bio.isEmpty || user.displayLocation != nil || !user.interests.isEmpty {
                    ProfileDetailsView(user: user)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                }
                
                // Tab Selector
                ProfileTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                // Content based on selected tab
                Group {
                    if selectedTab == 0 {
                        // Events Tab
                        if userEvents.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: isOwnProfile ? "No events yet" : "\(user.fullName) hasn't created any events",
                                subtitle: isOwnProfile ? "Create your first event to get started!" : "Check back later for updates"
                            )
                        } else {
                            LazyVStack(spacing: DesignSystem.Spacing.md) {
                                ForEach(userEvents, id: \.id) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        UserEventCard(event: event, host: user)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                        }
                    } else {
                        // Photos Tab
                        if userPhotos.isEmpty {
                            EmptyStateView(
                                icon: "photo",
                                title: isOwnProfile ? "No photos yet" : "\(user.fullName) hasn't shared any photos",
                                subtitle: isOwnProfile ? "Share photos from events you attend!" : "Check back later for updates"
                            )
                        } else {
                            PhotoGridView(photos: userPhotos)
                                .padding(.horizontal, DesignSystem.Spacing.xl)
                        }
                    }
                }
                
                Spacer(minLength: DesignSystem.Spacing.huge)
            }
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadUserData()
        }
        .refreshable {
            await loadUserData()
        }
    }
    
    // MARK: - Data Loading
    private func loadUserData() async {
        isLoading = true
        defer { isLoading = false }
        
        let api = AppContainer.shared.api
        
        async let events = api.getEventsForUser(userId: user.id)
        async let photos = api.getUserPhotos(for: user.id)
        
        // Check if current user is following this user
        if let currentUserId = currentUser?.id {
            let follows = await api.getFollows(for: currentUserId)
            isFollowing = follows.contains { $0.followingId == user.id }
        }
        
        userEvents = await events
        userPhotos = await photos
    }
    
    // MARK: - Actions
    private func handleFollowToggle() {
        guard let currentUserId = currentUser?.id else { return }
        
        Task {
            let api = AppContainer.shared.api
            if isFollowing {
                await api.unfollow(followerId: currentUserId, followingId: user.id)
            } else {
                await api.follow(followerId: currentUserId, followingId: user.id)
            }
            isFollowing.toggle()
            
            // Update user store
            await userStore.bootstrap(with: api)
        }
    }
    
    private func handleMessage() {
        // TODO: Implement messaging functionality
        print("Message user: \(user.fullName)")
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    let user: User
    @Binding var isFollowing: Bool
    let isOwnProfile: Bool
    let onFollowTap: () -> Void
    let onMessageTap: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Cover Photo
            ZStack {
                if let coverImageData = user.coverImageData, let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                } else {
                    // Default gradient cover
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 160)
                }
                
                // Profile avatar positioned over cover
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            AvatarView(data: user.avatarData, size: 100)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.surface, lineWidth: 4)
                                )
                                .designSystemShadow(DesignSystem.Shadows.medium)
                            
                            // Verification badge if verified
                            if user.isVerified {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .font(.caption)
                                    Text("Verified")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .cornerRadius(DesignSystem.CornerRadius.pill)
                            }
                        }
                        
                        Spacer()
                        
                        // Action buttons
                        if !isOwnProfile {
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Button(action: onFollowTap) {
                                    HStack {
                                        Image(systemName: isFollowing ? "person.fill.checkmark" : "person.fill.badge.plus")
                                        Text(isFollowing ? "Following" : "Follow")
                                    }
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(isFollowing ? DesignSystem.Colors.text : .white)
                                    .padding(.horizontal, DesignSystem.Spacing.lg)
                                    .padding(.vertical, DesignSystem.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                            .fill(isFollowing ? DesignSystem.Colors.secondaryBackground : DesignSystem.Colors.primary)
                                    )
                                }
                                
                                Button(action: onMessageTap) {
                                    HStack {
                                        Image(systemName: "message")
                                        Text("Message")
                                    }
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.text)
                                    .padding(.horizontal, DesignSystem.Spacing.lg)
                                    .padding(.vertical, DesignSystem.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                            .fill(DesignSystem.Colors.secondaryBackground)
                                    )
                                }
                            }
                            .padding(.trailing, DesignSystem.Spacing.lg)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
            }
            .cornerRadius(DesignSystem.CornerRadius.xl)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            
            // User Info
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(user.fullName)
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.text)
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                // User Type and Badge
                HStack(spacing: DesignSystem.Spacing.sm) {
                    UserTypeBadge(userType: user.userType)
                    
                    if let badge = user.badge {
                        Text(badge)
                            .font(DesignSystem.Typography.caption)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .background(DesignSystem.Colors.accent.opacity(0.1))
                            .foregroundColor(DesignSystem.Colors.accent)
                            .cornerRadius(DesignSystem.CornerRadius.pill)
                    }
                }
            }
        }
    }
}

// MARK: - Profile Stats View
struct ProfileStatsView: View {
    let followerCount: Int
    let followingCount: Int
    let eventCount: Int
    let photoCount: Int
    
    var body: some View {
        HStack {
            ProfileStatItem(title: "Followers", count: followerCount)
            Divider().frame(height: 30)
            ProfileStatItem(title: "Following", count: followingCount)
            Divider().frame(height: 30)
            ProfileStatItem(title: "Events", count: eventCount)
            Divider().frame(height: 30)
            ProfileStatItem(title: "Photos", count: photoCount)
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

struct ProfileStatItem: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(count)")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Details View
struct ProfileDetailsView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Bio
            if !user.bio.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("About")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(user.bio)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            // Location
            if let location = user.displayLocation {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(location)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                }
            }
            
            // Contact Info (if public)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if user.showEmail, let email = user.email {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text(email)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Spacer()
                    }
                }
                
                if user.showPhone, let phone = user.phoneNumber {
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text(phone)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Spacer()
                    }
                }
                
                if let website = user.website {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text(website)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primary)
                        Spacer()
                    }
                }
            }
            
            // Interests
            if !user.interests.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Interests")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    ModernChipsView(chips: user.interests)
                }
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

// MARK: - Profile Tab Selector
struct ProfileTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ProfileTabButton(title: "Events", icon: "calendar", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            ProfileTabButton(title: "Photos", icon: "photo", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.lg)
    }
}

struct ProfileTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - User Event Card
struct UserEventCard: View {
    let event: Event
    let host: User
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Event date
            VStack {
                Text(event.startDate.formatted(.dateTime.month().day()))
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                Text(event.startDate.formatted(.dateTime.year()))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(event.title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                
                Text(event.location)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "person.3")
                        .font(.caption)
                    Text("\(event.attendeeIds.count) attending")
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.all, DesignSystem.Spacing.lg)
        .modernCardStyle()
    }
}

// MARK: - Photo Grid View
struct PhotoGridView: View {
    let photos: [EventPhoto]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(photos, id: \.id) { photo in
                if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        )
                }
            }
        }
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text(title)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.all, DesignSystem.Spacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Extension for MockAPIService
extension MockAPIService {
    func getEventsForUser(userId: UUID) async -> [Event] {
        return events.filter { $0.hostId == userId }.sorted { $0.createdAt > $1.createdAt }
    }
}