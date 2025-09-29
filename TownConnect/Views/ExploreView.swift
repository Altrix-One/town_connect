import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    @State private var query = ""

    var filteredUsers: [User] {
        if query.isEmpty { return userStore.users }
        return userStore.users.filter { $0.username.localizedCaseInsensitiveContains(query) || $0.fullName.localizedCaseInsensitiveContains(query) }
    }

    var filteredEvents: [Event] {
        if query.isEmpty { return eventStore.events }
        return eventStore.events.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.location.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredUsers.isEmpty {
                    Section("Users") {
                        ForEach(filteredUsers) { user in
                            ExploreUserCard(user: user)
                        }
                    }
                }
                if !filteredEvents.isEmpty {
                    Section("Events") {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                    Text(event.location).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $query)
            .navigationTitle("Explore")
        }
    }
}

// MARK: - Explore User Card
struct ExploreUserCard: View {
    @EnvironmentObject var userStore: UserStore
    let user: User
    
    private var isFollowing: Bool {
        userStore.following.contains(user.id)
    }
    
    private var isCurrentUser: Bool {
        user.id == userStore.currentUser?.id
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // User Avatar
            AvatarView(data: user.avatarData, size: 48)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(user.fullName)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                Text("@\(user.username)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                // User Stats
                HStack(spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "person.3")
                            .font(.caption2)
                        Text("\(user.followerCount)")
                            .font(DesignSystem.Typography.caption)
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("\(user.eventCount)")
                            .font(DesignSystem.Typography.caption)
                    }
                    
                    if let location = user.displayLocation {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "location")
                                .font(.caption2)
                            Text(location)
                                .font(DesignSystem.Typography.caption)
                                .lineLimit(1)
                        }
                    }
                }
                .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            // Follow Button (only for other users)
            if !isCurrentUser {
                Button(action: handleFollowToggle) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: isFollowing ? "person.fill.checkmark" : "person.fill.badge.plus")
                            .font(.caption)
                        Text(isFollowing ? "Following" : "Follow")
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(isFollowing ? DesignSystem.Colors.textSecondary : .white)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(isFollowing ? DesignSystem.Colors.secondaryBackground : DesignSystem.Colors.primary)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.all, DesignSystem.Spacing.md)
    }
    
    private func handleFollowToggle() {
        guard let currentUserId = userStore.currentUser?.id else { return }
        
        Task {
            let api = AppContainer.shared.api
            if isFollowing {
                await userStore.unfollow(userId: user.id, api: api)
            } else {
                await userStore.follow(userId: user.id, api: api)
            }
        }
    }
}
