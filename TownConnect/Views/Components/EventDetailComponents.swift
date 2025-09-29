import SwiftUI
import PhotosUI

// MARK: - Event Header View
struct EventHeaderView: View {
    let event: Event
    let host: User?
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Cover Image or Gradient
            ZStack {
                if let coverImageData = event.coverImageData, let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    // Gradient background based on event category
                    categoryGradient(for: event.category)
                        .frame(height: 200)
                }
                
                // Overlay for better text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                // Event Title and Host
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(event.title)
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            
                            if let host = host {
                                Text("Hosted by \(host.fullName)")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
            .cornerRadius(DesignSystem.CornerRadius.xl)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }
    
    private func categoryGradient(for category: EventCategory) -> LinearGradient {
        switch category {
        case .community:
            return LinearGradient(colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sports:
            return LinearGradient(colors: [DesignSystem.Colors.success, Color.green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .food:
            return LinearGradient(colors: [DesignSystem.Colors.accent, Color.orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .music:
            return LinearGradient(colors: [Color.purple, Color.pink.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
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
            // RSVP Title
            Text("Will you be attending?")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.text)
            
            // RSVP Poll Visual
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Going
                RSVPOptionView(
                    title: "Going",
                    count: attendeeCount,
                    status: .accepted,
                    currentUserStatus: userRSVPStatus,
                    onTap: { onRSVPTap(.accepted) }
                )
                
                // Not Going  
                RSVPOptionView(
                    title: "Can't Go",
                    count: notAttendingCount,
                    status: .declined,
                    currentUserStatus: userRSVPStatus,
                    onTap: { onRSVPTap(.declined) }
                )
                
                // Maybe
                RSVPOptionView(
                    title: "Maybe",
                    count: 0, // Could track this separately
                    status: .maybe,
                    currentUserStatus: userRSVPStatus,
                    onTap: { onRSVPTap(.maybe) }
                )
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

// MARK: - RSVP Option View
struct RSVPOptionView: View {
    let title: String
    let count: Int
    let status: RSVPStatus
    let currentUserStatus: RSVPStatus
    let onTap: () -> Void
    
    var isSelected: Bool { currentUserStatus == status }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Icon
                Image(systemName: iconForStatus(status))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : colorForStatus(status))
                
                // Count
                Text("\(count)")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
                
                // Title
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(isSelected ? colorForStatus(status) : DesignSystem.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(colorForStatus(status).opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func iconForStatus(_ status: RSVPStatus) -> String {
        switch status {
        case .accepted: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        case .maybe: return "questionmark.circle.fill"
        default: return "circle"
        }
    }
    
    private func colorForStatus(_ status: RSVPStatus) -> Color {
        switch status {
        case .accepted: return DesignSystem.Colors.success
        case .declined: return DesignSystem.Colors.error
        case .maybe: return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.primary
        }
    }
}

// MARK: - Event Details View
struct EventDetailsView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Date and Time
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(DesignSystem.Colors.primary)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(event.startDate.formatted(date: .complete, time: .omitted))
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                Spacer()
            }
            
            // Location
            HStack {
                Image(systemName: "location")
                    .foregroundColor(DesignSystem.Colors.primary)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(event.location)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                Spacer()
            }
            
            // Description
            if !event.details.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("About this event")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(event.details)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Tags
            if !event.tags.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Tags")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignSystem.Spacing.sm) {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(DesignSystem.Typography.caption)
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                                )
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
    }
}

// MARK: - Attendee Preview View
struct AttendeePreviewView: View {
    let attendees: [User]
    let totalCount: Int
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Attendees (\(totalCount))")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                if totalCount > 6 {
                    Button("View All", action: onViewAll)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            if !attendees.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: DesignSystem.Spacing.sm) {
                    ForEach(attendees.prefix(6), id: \.id) { user in
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            AvatarView(data: user.avatarData, size: 40)
                            Text(user.fullName.components(separatedBy: " ").first ?? "")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            } else {
                Text("Be the first to RSVP!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DesignSystem.Spacing.lg)
            }
        }
        .padding(.all, DesignSystem.Spacing.xl)
        .modernCardStyle()
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
        VStack(spacing: DesignSystem.Spacing.md) {
            // Reaction summary
            if !reactions.isEmpty {
                HStack {
                    ForEach(ReactionType.allCases, id: \.self) { type in
                        let count = reactions.filter { $0.type == type }.count
                        if count > 0 {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Text(type.emoji)
                                Text("\(count)")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                    Spacer()
                    
                    if commentCount > 0 {
                        Text("\(commentCount) comments")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            
            Divider()
            
            // Action buttons
            HStack(spacing: DesignSystem.Spacing.xl) {
                Button(action: { onReaction(.like) }) {
                    HStack {
                        Image(systemName: "heart")
                        Text("Like")
                    }
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Button(action: onComment) {
                    HStack {
                        Image(systemName: "bubble.right")
                        Text("Comment")
                    }
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Button(action: onShare) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.all, DesignSystem.Spacing.lg)
        .modernCardStyle()
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    let onAddToCalendar: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button("Add to Calendar", action: onAddToCalendar)
                .buttonStyle(PrimaryButtonStyle())
            
            Button("Share Event", action: onShare)
                .buttonStyle(SecondaryButtonStyle())
        }
    }
}

// MARK: - Event Photos View
struct EventPhotosView: View {
    let photos: [EventPhoto]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Event Photos")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(photos.prefix(10), id: \.id) { photo in
                        if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(DesignSystem.CornerRadius.md)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
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
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        ForEach(comments, id: \.id) { comment in
                            CommentRowView(comment: comment)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
                
                Divider()
                
                // Comment input
                HStack {
                    TextField("Add a comment...", text: $newComment, axis: .vertical)
                        .textFieldStyle(MagicalTextFieldStyle())
                        .lineLimit(1...4)
                    
                    Button("Post", action: {
                        onSubmitComment()
                        dismiss()
                    })
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    @EnvironmentObject var userStore: UserStore
    
    var author: User? {
        userStore.users.first { $0.id == comment.userId }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            AvatarView(data: author?.avatarData, size: 32)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(author?.fullName ?? "Unknown User")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
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
        .padding(.all, DesignSystem.Spacing.md)
        .modernCardStyle()
    }
}

// MARK: - Attendee List View
struct AttendeeListView: View {
    let attendees: [User]
    let event: Event
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
                                .cornerRadius(DesignSystem.CornerRadius.sm)
                        }
                    }
                }
            }
            .navigationTitle("Attendees (\(attendees.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}