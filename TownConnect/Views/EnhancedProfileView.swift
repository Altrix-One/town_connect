import SwiftUI
import PhotosUI

struct EnhancedProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var userPhotos: [EventPhoto] = []
    @State private var userEvents: [Event] = []
    @State private var attendedEvents: [Event] = []
    @State private var selectedTab = 0 // 0: Grid, 1: Events, 2: Attended
    @State private var showEditProfile = false
    @State private var isLoading = false
    
    private var currentUser: User? { userStore.currentUser }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Profile Header with Cover Image
                ProfileCoverSection(user: currentUser, onEditTap: { showEditProfile = true })
                
                // Profile Stats Section
                InstagramStatsSection(user: currentUser)
                
                // Action Buttons Section
                ProfileActionButtonsSection(user: currentUser, onEditTap: { showEditProfile = true })
                
                // Highlights Section (Stories-style)
                if let user = currentUser, !user.interests.isEmpty {
                    ProfileHighlightsSection(interests: user.interests)
                }
                
                // Tab Bar
                InstagramTabBar(selectedTab: $selectedTab)
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        PhotoGridSection(photos: userPhotos)
                    case 1:
                        EventsGridSection(events: userEvents)
                    case 2:
                        AttendedEventsSection(events: attendedEvents)
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .task {
            await loadProfileData()
        }
        .refreshable {
            await loadProfileData()
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = currentUser {
                EditProfileView(user: user)
            }
        }
        .photosPicker(isPresented: .constant(false), selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
        .onChange(of: selectedPhotos) { _, newItems in
            handleSelectedPhotos(newItems)
        }
    }
    
    // MARK: - Data Loading
    private func loadProfileData() async {
        guard let currentUser = currentUser else { return }
        isLoading = true
        defer { isLoading = false }
        
        let api = AppContainer.shared.api
        
        async let photos = api.getUserPhotos(for: currentUser.id)
        async let events = api.getEventsForUser(userId: currentUser.id)
        async let attended = api.getAttendedEvents(for: currentUser.id)
        
        userPhotos = await photos
        userEvents = await events
        attendedEvents = await attended
    }
    
    // MARK: - Photo Handling
    private func handleSelectedPhotos(_ items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let imageData = data {
                            // Create a new photo (would be associated with an event in real implementation)
                            let photo = EventPhoto(
                                eventId: userEvents.first?.id ?? UUID(),
                                userId: currentUser?.id ?? UUID(),
                                imageData: imageData
                            )
                            userPhotos.insert(photo, at: 0)
                        }
                    case .failure(let error):
                        print("Failed to load photo: \(error)")
                    }
                }
            }
        }
        selectedPhotos = []
    }
}

// MARK: - Profile Cover Section
struct ProfileCoverSection: View {
    let user: User?
    let onEditTap: () -> Void
    
    var body: some View {
        ZStack {
            // Cover Image
            if let user = user, let coverImageData = user.coverImageData, let uiImage = UIImage(data: coverImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } else {
                // Default gradient cover
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary,
                        DesignSystem.Colors.primaryLight,
                        DesignSystem.Colors.accent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
            }
            
            // Profile Info Overlay
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        // Profile Avatar
                        HStack {
                            AvatarView(data: user?.avatarData, size: 90)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.surface, lineWidth: 4)
                                )
                                .designSystemShadow(DesignSystem.Shadows.large)
                            
                            Spacer()
                        }
                        
                        // User Name and Handle
                        if let user = user {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Text(user.fullName)
                                        .font(DesignSystem.Typography.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if user.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                    }
                                }
                                
                                Text("@\(user.username)")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                if let badge = user.badge {
                                    Text(badge)
                                        .font(DesignSystem.Typography.caption)
                                        .padding(.horizontal, DesignSystem.Spacing.sm)
                                        .padding(.vertical, DesignSystem.Spacing.xs)
                                        .background(.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(DesignSystem.CornerRadius.pill)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Edit Button
                    Button(action: onEditTap) {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.all, DesignSystem.Spacing.md)
                            .background(.white.opacity(0.2))
                            .cornerRadius(DesignSystem.CornerRadius.lg)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
        }
    }
}

// MARK: - Instagram Stats Section
struct InstagramStatsSection: View {
    let user: User?
    
    var body: some View {
        if let user = user {
            HStack {
                InstagramStatItem(title: "Posts", count: user.photoCount + user.eventCount)
                InstagramStatItem(title: "Followers", count: user.followerCount)
                InstagramStatItem(title: "Following", count: user.followingCount)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }
}

struct InstagramStatItem: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(count)")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Action Buttons Section
struct ProfileActionButtonsSection: View {
    let user: User?
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Bio
            if let user = user, !user.bio.isEmpty {
                Text(user.bio)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            // Location and Contact Info
            if let user = user {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    if let location = user.displayLocation {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "location")
                                .foregroundColor(DesignSystem.Colors.primary)
                                .font(.caption)
                            Text(location)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    if let website = user.website {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "link")
                                .foregroundColor(DesignSystem.Colors.primary)
                                .font(.caption)
                            Text(website)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                Button(action: onEditTap) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                        Text("Edit Profile")
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.md)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Profile")
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.md)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }
}

// MARK: - Profile Highlights Section
struct ProfileHighlightsSection: View {
    let interests: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Highlights")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(.leading, DesignSystem.Spacing.xl)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(Array(interests.prefix(5)), id: \.self) { interest in
                        HighlightCircle(title: interest)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
}

struct HighlightCircle: View {
    let title: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    Text(String(title.prefix(1)).uppercased())
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

// MARK: - Instagram Tab Bar
struct InstagramTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            InstagramTabButton(
                icon: "grid",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            InstagramTabButton(
                icon: "calendar",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            InstagramTabButton(
                icon: "heart",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
    }
}

struct InstagramTabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Photo Grid Section
struct PhotoGridSection: View {
    let photos: [EventPhoto]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        if photos.isEmpty {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text("No Photos Yet")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Share photos from events to showcase your experiences!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.all, DesignSystem.Spacing.xxxl)
        } else {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(photos, id: \.id) { photo in
                    PhotoGridItem(photo: photo)
                }
            }
        }
    }
}

struct PhotoGridItem: View {
    let photo: EventPhoto
    
    var body: some View {
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

// MARK: - Events Grid Section
struct EventsGridSection: View {
    let events: [Event]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 2)
    
    var body: some View {
        if events.isEmpty {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text("No Events Created")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Create your first event to bring your community together!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.all, DesignSystem.Spacing.xxxl)
        } else {
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(events, id: \.id) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventGridCard(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

struct EventGridCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Event Image or Placeholder
            if let imageData = event.coverImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fill)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.md)
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .aspectRatio(4/3, contentMode: .fit)
                    .cornerRadius(DesignSystem.CornerRadius.md)
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.title)
                            .foregroundColor(.white)
                    )
            }
            
            // Event Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(event.title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                
                Text(event.startDate.formatted(.dateTime.month().day().hour().minute()))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                HStack {
                    Image(systemName: "person.3")
                        .font(.caption2)
                    Text("\(event.attendeeIds.count)")
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(.all, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .designSystemShadow(DesignSystem.Shadows.small)
    }
}

// MARK: - Attended Events Section
struct AttendedEventsSection: View {
    let events: [Event]
    
    var body: some View {
        if events.isEmpty {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text("No Events Attended")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("RSVP to events you're interested in and they'll appear here!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.all, DesignSystem.Spacing.xxxl)
        } else {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(events, id: \.id) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        AttendedEventCard(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }
}

struct AttendedEventCard: View {
    let event: Event
    
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
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.success)
                    Text("Attended")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }
            
            Spacer()
        }
        .padding(.all, DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .designSystemShadow(DesignSystem.Shadows.small)
    }
}

// MARK: - Extension for MockAPIService
extension MockAPIService {
    func getAttendedEvents(for userId: UUID) async -> [Event] {
        return events.filter { $0.attendeeIds.contains(userId) }.sorted { $0.startDate < $1.startDate }
    }
}