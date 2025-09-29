import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    @State private var showingWelcome = false

    private var feedEvents: [Event] {
        guard let me = userStore.currentUser else { return [] }
        let following = userStore.following.union([me.id])
        return eventStore.events.filter { following.contains($0.hostId) }
    }
    
    private var welcomeMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = {
            switch hour {
            case 0..<12: return "Good morning"
            case 12..<17: return "Good afternoon"
            default: return "Good evening"
            }
        }()
        
        if let user = userStore.currentUser {
            return "\(greeting), \(user.fullName.components(separatedBy: " ").first ?? user.username)!"
        }
        return "\(greeting)!"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // Welcome Header
                    WelcomeHeader(
                        message: welcomeMessage,
                        userType: userStore.currentUser?.userType ?? .resident
                    )
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Quick Stats
                    if let currentUser = userStore.currentUser {
                        QuickStatsView(
                            followingCount: userStore.following.count,
                            eventsCount: feedEvents.count,
                            userType: currentUser.userType
                        )
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                    
                    // Feed Section
                    if feedEvents.isEmpty {
                        EmptyFeedView()
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                    } else {
                        LazyVStack(spacing: DesignSystem.Spacing.lg) {
                            ForEach(feedEvents) { event in
                                NavigationLink(value: event.id) {
                                    ModernEventCard(event: event, userStore: userStore)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(for: UUID.self) { id in
                if let event = eventStore.events.first(where: { $0.id == id }) {
                    EventDetailView(event: event)
                }
            }
            .refreshable {
                // TODO: Refresh feed data
            }
        }
    }
}

// MARK: - Supporting Components

struct WelcomeHeader: View {
    let message: String
    let userType: UserType
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(message)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("What's happening in your community?")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            UserTypeBadge(userType: userType)
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary.opacity(0.1), DesignSystem.Colors.primaryLight.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct QuickStatsView: View {
    let followingCount: Int
    let eventsCount: Int
    let userType: UserType
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            StatItem(title: "Following", value: "\(followingCount)", icon: "person.2.fill")
            StatItem(title: "Events", value: "\(eventsCount)", icon: "calendar.circle.fill")
            StatItem(title: "Role", value: userType.displayName, icon: "shield.fill")
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(value)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .modernCardStyle()
    }
}

struct ModernEventCard: View {
    let event: Event
    let userStore: UserStore
    
    private var host: User? {
        userStore.users.first { $0.id == event.hostId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Event Header
            HStack(spacing: DesignSystem.Spacing.md) {
                // Host Avatar
                AvatarView(data: host?.avatarData)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(host?.fullName ?? "Unknown Host")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(event.startDate.timeAgoDisplay())
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                if let hostType = host?.userType {
                    Image(systemName: hostType == .businessOwner ? "briefcase.fill" : "person.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .padding(6)
                        .background(
                            Circle().fill(DesignSystem.Colors.primary.opacity(0.1))
                        )
                }
            }
            
            // Event Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text(event.title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                
                if !event.details.isEmpty {
                    Text(event.details)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                // Event Details
                VStack(spacing: DesignSystem.Spacing.xs) {
                    EventDetailRow(icon: "location.fill", text: event.location)
                    EventDetailRow(icon: "calendar", text: event.startDate.formatted(date: .abbreviated, time: .shortened))
                    
                    if !event.attendeeIds.isEmpty {
                        EventDetailRow(
                            icon: "person.2.fill",
                            text: "\(event.attendeeIds.count) attending"
                        )
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .elevatedCardStyle()
    }
}

struct EventDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 16)
            
            Text(text)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
        }
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "house.circle")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Your feed is empty")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Follow community members and event organizers to see their events here.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Explore Community") {
                // TODO: Navigate to explore tab
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

// MARK: - Date Extension
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
