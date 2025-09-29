import SwiftUI
import PhotosUI

// MARK: - Event Header View
struct EventHeaderView: View {
    let event: Event
    let host: User?
    
    var body: some View {
        VStack(spacing: 0) {
            // Cover Image
            Group {
                if let imageData = event.coverImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
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
                    .frame(height: 240)
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                    )
                }
            }
            .overlay(
                // Event Info Overlay
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            // Event Title
                            Text(event.title)
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                            
                            // Date and Time
                            Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(radius: 1)
                            
                            // Location
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "location")
                                    .font(.caption)
                                Text(event.location)
                                    .font(DesignSystem.Typography.body)
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 1)
                        }
                        
                        Spacer()
                        
                        // Host Avatar
                        if let host = host {
                            VStack(spacing: DesignSystem.Spacing.xs) {
                                AvatarView(data: host.avatarData, size: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                    )
                                    .shadow(radius: 4)
                                
                                Text("Host: \(host.fullName)")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            )
            .cornerRadius(DesignSystem.CornerRadius.xl)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }
}

// MARK: - RSVP Section View
struct RSVPSectionView: View {
    @Binding var userRSVPStatus: RSVPStatus
    let attendeeCount: Int
    let notAttendingCount: Int
    let onRSVPTap: (RSVPStatus) -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // RSVP Status Display
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Are you going?")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                // Current Status
                Text(currentStatusText)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                            .fill(statusColor.opacity(0.1))
                    )
            }
            
            // RSVP Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                RSVPButton(
                    title: "Going",
                    icon: "checkmark.circle.fill",
                    status: .accepted,
                    currentStatus: userRSVPStatus,
                    count: attendeeCount,
                    onTap: { onRSVPTap(.accepted) }
                )
                
                RSVPButton(
                    title: "Maybe",
                    icon: "questionmark.circle.fill",
                    status: .maybe,
                    currentStatus: userRSVPStatus,
                    count: 0, // Maybe count would need separate tracking
                    onTap: { onRSVPTap(.maybe) }
                )
                
                RSVPButton(
                    title: "Can't Go",
                    icon: "xmark.circle.fill",
                    status: .declined,
                    currentStatus: userRSVPStatus,
                    count: notAttendingCount,
                    onTap: { onRSVPTap(.declined) }
                )
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
    
    private var currentStatusText: String {
        switch userRSVPStatus {
        case .accepted:
            return "You're going! 🎉"
        case .declined:
            return "You can't make it"
        case .maybe:
            return "You might go"
        case .invited:
            return "Please respond"
        }
    }
    
    private var statusColor: Color {
        switch userRSVPStatus {
        case .accepted:
            return DesignSystem.Colors.success
        case .declined:
            return DesignSystem.Colors.error
        case .maybe:
            return DesignSystem.Colors.warning
        case .invited:
            return DesignSystem.Colors.textSecondary
        }
    }
}

struct RSVPButton: View {
    let title: String
    let icon: String
    let status: RSVPStatus
    let currentStatus: RSVPStatus
    let count: Int
    let onTap: () -> Void
    
    private var isSelected: Bool {
        currentStatus == status
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : statusColor)
                
                Text(title)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(isSelected ? .white : statusColor)
                
                if count > 0 {
                    Text("\(count)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : statusColor.opacity(0.7))
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(isSelected ? statusColor : statusColor.opacity(0.1))
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var statusColor: Color {
        switch status {
        case .accepted:
            return DesignSystem.Colors.success
        case .declined:
            return DesignSystem.Colors.error
        case .maybe:
            return DesignSystem.Colors.warning
        case .invited:
            return DesignSystem.Colors.primary
        }
    }
}

// MARK: - Event Details View
struct EventDetailsView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Description
            if !event.details.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("About this event")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(event.details)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            // Event Details Grid
            VStack(spacing: DesignSystem.Spacing.md) {
                EventDetailRow(
                    icon: "calendar",
                    title: "Date & Time",
                    value: "\(event.startDate.formatted(date: .abbreviated, time: .shortened)) - \(event.endDate.formatted(time: .shortened))",
                    color: DesignSystem.Colors.primary
                )
                
                EventDetailRow(
                    icon: "location",
                    title: "Location",
                    value: event.location,
                    color: DesignSystem.Colors.accent
                )
                
                if event.maxAttendees != nil {
                    EventDetailRow(
                        icon: "person.3",
                        title: "Capacity",
                        value: "\(event.attendeeIds.count)/\(event.maxAttendees!) attendees",
                        color: DesignSystem.Colors.warning
                    )
                }
                
                if !event.tags.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .frame(width: 20)
                            Text("Tags")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.text)
                            Spacer()
                        }
                        
                        ModernChipsView(chips: event.tags)
                            .padding(.leading, 28)
                    }
                }
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

struct EventDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                Text(value)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Attendee Preview View
struct AttendeePreviewView: View {
    let attendees: [User]
    let totalCount: Int
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Going (\(totalCount))")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                if totalCount > attendees.count {
                    Button("View All", action: onViewAll)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            if attendees.isEmpty {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "person.2")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No one's going yet")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Be the first to RSVP!")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(attendees, id: \.id) { user in
                            AttendeeAvatarView(user: user)
                        }
                        
                        if totalCount > attendees.count {
                            Button(action: onViewAll) {
                                VStack(spacing: DesignSystem.Spacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(DesignSystem.Colors.secondaryBackground)
                                            .frame(width: 60, height: 60)
                                        
                                        Text("+\(totalCount - attendees.count)")
                                            .font(DesignSystem.Typography.captionMedium)
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                    
                                    Text("More")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                }
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

struct AttendeeAvatarView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            AvatarView(data: user.avatarData, size: 60)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.success, lineWidth: 2)
                )
            
            Text(user.fullName.components(separatedBy: " ").first ?? "")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

// MARK: - Event Photos View
struct EventPhotosView: View {
    let photos: [EventPhoto]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Photos (\(photos.count))")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(photos.prefix(9)), id: \.id) { photo in
                    EventPhotoThumbnail(photo: photo, showOverlay: photos.firstIndex(where: { $0.id == photo.id }) == 8 && photos.count > 9, remainingCount: photos.count - 9)
                }
            }
            .cornerRadius(DesignSystem.CornerRadius.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }
}

struct EventPhotoThumbnail: View {
    let photo: EventPhoto
    let showOverlay: Bool
    let remainingCount: Int
    
    var body: some View {
        Group {
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
        .overlay(
            Group {
                if showOverlay && remainingCount > 0 {
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.6))
                        
                        Text("+\(remainingCount)")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        )
    }
}

// MARK: - Social Interactions View
struct SocialInteractionsView: View {
    let reactions: [Reaction]
    let commentCount: Int
    let onReaction: (ReactionType) -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Reaction Summary
            if !reactions.isEmpty {
                ReactionSummaryView(reactions: reactions)
            }
            
            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.xl) {
                SocialActionButton(
                    icon: "heart",
                    title: "Like",
                    count: reactions.filter { $0.type == .like }.count,
                    color: DesignSystem.Colors.love,
                    action: { onReaction(.like) }
                )
                
                SocialActionButton(
                    icon: "bubble.right",
                    title: "Comment",
                    count: commentCount,
                    color: DesignSystem.Colors.primary,
                    action: onComment
                )
                
                SocialActionButton(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    count: 0,
                    color: DesignSystem.Colors.accent,
                    action: onShare
                )
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

struct ReactionSummaryView: View {
    let reactions: [Reaction]
    
    private var reactionCounts: [ReactionType: Int] {
        Dictionary(grouping: reactions, by: \.type)
            .mapValues { $0.count }
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(ReactionType.allCases.filter { reactionCounts[$0, default: 0] > 0 }, id: \.self) { type in
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(type.emoji)
                        .font(.title3)
                    
                    Text("\(reactionCounts[type, default: 0])")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
    }
}

struct SocialActionButton: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    let onAddToCalendar: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ActionButton(
                title: "Add to Calendar",
                icon: "calendar.badge.plus",
                color: DesignSystem.Colors.primary,
                action: onAddToCalendar
            )
            
            ActionButton(
                title: "Share Event",
                icon: "square.and.arrow.up",
                color: DesignSystem.Colors.accent,
                action: onShare
            )
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
            }
            .foregroundColor(.white)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(color)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Comments View
struct CommentsView: View {
    let eventId: UUID
    let comments: [Comment]
    @Binding var newComment: String
    let onSubmitComment: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Comments List
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(comments, id: \.id) { comment in
                            CommentRowView(comment: comment)
                        }
                    }
                    .padding(.all, DesignSystem.Spacing.xl)
                }
                
                // Comment Input
                HStack(spacing: DesignSystem.Spacing.md) {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Post") {
                        onSubmitComment()
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                .padding(.all, DesignSystem.Spacing.xl)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // User avatar placeholder
            Circle()
                .fill(DesignSystem.Colors.secondaryBackground)
                .frame(width: 36, height: 36)
                .overlay(
                    Text("U")
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text("User")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    Text(comment.createdAt.timeAgoDisplay())
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Text(comment.content)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Attendee List View
struct AttendeeListView: View {
    let attendees: [User]
    let event: Event
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(attendees, id: \.id) { user in
                    HStack(spacing: DesignSystem.Spacing.md) {
                        AvatarView(data: user.avatarData, size: 50)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(user.fullName)
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text("@\(user.username)")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        if user.id == event.hostId {
                            Text("Host")
                                .font(DesignSystem.Typography.caption)
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .foregroundColor(DesignSystem.Colors.primary)
                                .cornerRadius(DesignSystem.CornerRadius.pill)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xs)
                }
            }
            .navigationTitle("Attendees (\(attendees.count))")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}