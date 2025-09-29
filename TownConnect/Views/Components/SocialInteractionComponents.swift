import SwiftUI

// MARK: - Social Interaction Bar
struct SocialInteractionBar: View {
    let eventId: UUID?
    let photoId: UUID?
    let commentId: UUID?
    
    @State private var reactions: [Reaction] = []
    @State private var showingReactionPicker = false
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var commentCount = 0
    
    @EnvironmentObject var socialAPI: SocialAPIService
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Like button with animation
            Button {
                Task {
                    await toggleLike()
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isLiked ? DesignSystem.Colors.love : DesignSystem.Colors.textSecondary)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                        .animation(DesignSystem.Animation.heartbeat, value: isLiked)
                    
                    if likeCount > 0 {
                        Text("\\(likeCount)")
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            
            // Reaction picker button
            Button {
                showingReactionPicker = true
            } label: {
                Image(systemName: "face.smiling")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .popover(isPresented: $showingReactionPicker) {
                ReactionPickerView(
                    eventId: eventId,
                    photoId: photoId,
                    commentId: commentId
                )
                .environmentObject(socialAPI)
            }
            
            // Comment button
            Button {
                // Handle comment
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    if commentCount > 0 {
                        Text("\(commentCount)")
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Share button
            Button {
                // Handle share
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .task {
            await loadInteractionData()
        }
    }
    
    private func toggleLike() async {
        let wasLiked = isLiked
        
        // Optimistic update
        withAnimation(DesignSystem.Animation.heartbeat) {
            isLiked.toggle()
            likeCount += isLiked ? 1 : -1
        }
        
        do {
            if isLiked {
                let _ = try await socialAPI.addReaction(
                    to: eventId,
                    photoId: photoId,
                    commentId: commentId,
                    type: .like
                )
            } else {
                try await socialAPI.removeReaction(
                    from: eventId,
                    photoId: photoId,
                    commentId: commentId
                )
            }
        } catch {
            // Revert optimistic update on error
            withAnimation {
                isLiked = wasLiked
                likeCount += isLiked ? 1 : -1
            }
        }
    }
    
    private func loadInteractionData() async {
        // Load current reaction state and counts
        // This would typically come from the API
        // For now, using mock data
    }
}

// MARK: - Reaction Picker
struct ReactionPickerView: View {
    let eventId: UUID?
    let photoId: UUID?
    let commentId: UUID?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var socialAPI: SocialAPIService
    
    let reactions: [ReactionType] = ReactionType.allCases
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(reactions, id: \.self) { reaction in
                Button {
                    Task {
                        await addReaction(reaction)
                    }
                } label: {
                    Text(reaction.emoji)
                        .font(.title2)
                        .padding(DesignSystem.Spacing.sm)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surface)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                )
                        )
                }
                .scaleEffect(1.0)
                .onTapGesture {
                    withAnimation(DesignSystem.Animation.bounce) {
                        // Animation handled by button press
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(.thinMaterial)
        )
    }
    
    private func addReaction(_ type: ReactionType) async {
        do {
            let _ = try await socialAPI.addReaction(
                to: eventId,
                photoId: photoId,
                commentId: commentId,
                type: type
            )
            dismiss()
        } catch {
            // Handle error
        }
    }
}

// MARK: - Enhanced Event Card with Social Features
struct EnhancedEventCard: View {
    let event: Event
    let userStore: UserStore
    @EnvironmentObject var socialAPI: SocialAPIService
    
    @State private var isLiked = false
    @State private var showingPhotoTimeline = false
    
    private var host: User? {
        userStore.users.first { $0.id == event.hostId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with host info
            EventCardHeader(
                host: host,
                event: event,
                showingPhotoTimeline: $showingPhotoTimeline
            )
            
            // Event content with gradient background
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Event title and details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text(event.title)
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Category badge
                        CategoryBadge(category: event.category)
                    }
                    
                    if !event.details.isEmpty {
                        Text(event.details)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(3)
                    }
                }
                
                // Event metadata
                EventMetadataView(event: event)
                
                // Social interaction bar
                SocialInteractionBar(
                    eventId: event.id,
                    photoId: nil,
                    commentId: nil
                )
                .environmentObject(socialAPI)
            }
            .padding(DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
            )
        }
        .elevatedCardStyle()
        .sheet(isPresented: $showingPhotoTimeline) {
            PhotoTimelineView(event: event)
                .environmentObject(socialAPI)
        }
    }
}

// MARK: - Event Card Header
struct EventCardHeader: View {
    let host: User?
    let event: Event
    @Binding var showingPhotoTimeline: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Host avatar with gradient border
            AvatarView(data: host?.avatarData)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .padding(-2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(host?.fullName ?? "Unknown Host")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if host?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                Text(event.startDate.timeAgoDisplay())
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Photo timeline button
            Button {
                showingPhotoTimeline = true
            } label: {
                Image(systemName: "photo.stack")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(DesignSystem.Spacing.sm)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.1),
                            DesignSystem.Colors.accent.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: EventCategory
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: category.icon)
                .font(.caption2)
            
            Text(category.displayName)
                .font(DesignSystem.Typography.captionMedium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(categoryGradient(for: category))
        )
        .designSystemShadow(DesignSystem.Shadows.light)
    }
    
    private func categoryGradient(for category: EventCategory) -> LinearGradient {
        switch category {
        case .community: return DesignSystem.Gradients.communityGradient
        case .sports: return DesignSystem.Gradients.sportsGradient
        case .culture: return DesignSystem.Gradients.cultureGradient
        case .food: return DesignSystem.Gradients.foodGradient
        default: return DesignSystem.Gradients.primaryGradient
        }
    }
}

// MARK: - Event Metadata View
struct EventMetadataView: View {
    let event: Event
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(width: 16)
                
                Text(event.location)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
            }
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(width: 16)
                
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
            }
            
            if !event.attendeeIds.isEmpty {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 16)
                    
                    Text("\(event.attendeeIds.count) attending")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Avatar View with Gradient Border
struct AvatarView: View {
    let data: Data?
    let size: CGFloat
    
    init(data: Data?, size: CGFloat = 40) {
        self.data = data
        self.size = size
    }
    
    var body: some View {
        Group {
            if let data = data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: size * 0.8))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(DesignSystem.Colors.border.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedEventCard(
            event: Event(
                title: "Community Art Festival",
                details: "Join us for a celebration of local art and culture with live performances, food trucks, and interactive workshops.",
                location: "Downtown Art District",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200),
                hostId: UUID(),
                attendeeIds: [UUID(), UUID(), UUID(), UUID()],
                category: .culture,
                likeCount: 12,
                commentCount: 5
            ),
            userStore: UserStore()
        )
        .environmentObject(SocialAPIService(supabaseService: SupabaseService.shared))
        
        SocialInteractionBar(
            eventId: UUID(),
            photoId: nil,
            commentId: nil
        )
        .environmentObject(SocialAPIService(supabaseService: SupabaseService.shared))
        .glassMaterial()
    }
    .padding()
    .background(DesignSystem.Colors.background)
}