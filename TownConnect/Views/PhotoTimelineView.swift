import SwiftUI

struct PhotoTimelineView: View {
    let event: Event
    @EnvironmentObject var socialAPI: SocialAPIService
    @State private var eventPhotos: [EventPhoto] = []
    @State private var isLoading = false
    @State private var showingPhotoSharing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                DesignSystem.Gradients.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.lg) {
                        // Header
                        EventTimelineHeader(event: event) {
                            showingPhotoSharing = true
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        
                        // Photos grid
                        if eventPhotos.isEmpty {
                            EmptyTimelineView {
                                showingPhotoSharing = true
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                        } else {
                            PhotoMasonryGrid(photos: eventPhotos)
                                .padding(.horizontal, DesignSystem.Spacing.xl)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
                .refreshable {
                    await loadEventPhotos()
                }
            }
            .navigationTitle("Event Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPhotoSharing) {
                PhotoSharingSheetView(event: event)
                    .environmentObject(socialAPI)
            }
            .task {
                await loadEventPhotos()
            }
        }
    }
    
    private func loadEventPhotos() async {
        isLoading = true
        
        do {
            let photos = try await socialAPI.getEventPhotos(for: event.id)
            await MainActor.run {
                eventPhotos = photos.sorted { $0.createdAt > $1.createdAt }
            }
        } catch {
            // Handle error silently for now
            print("Failed to load photos: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct EventTimelineHeader: View {
    let event: Event
    let onAddPhoto: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Share your moments from this event")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button {
                    onAddPhoto()
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            Circle()
                                .fill(DesignSystem.Gradients.primaryGradient)
                        )
                        .designSystemShadow(DesignSystem.Shadows.medium)
                }
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .vibrantGlassMaterial()
    }
}

struct PhotoMasonryGrid: View {
    let photos: [EventPhoto]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(photos) { photo in
                PhotoTimelineCard(photo: photo)
            }
        }
    }
}

struct PhotoTimelineCard: View {
    let photo: EventPhoto
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            Group {
                if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(DesignSystem.Colors.surface)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        )
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(height: 200)
            .clipped()
            
            // Caption and interactions
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if !photo.caption.isEmpty {
                    Text(photo.caption)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(3)
                }
                
                HStack {
                    // Like button
                    Button {
                        // Handle like
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.caption)
                            Text("\(photo.likeCount)")
                                .font(DesignSystem.Typography.caption)
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(photo.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .socialCardStyle()
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            PhotoDetailView(photo: photo)
        }
    }
}

struct EmptyTimelineView: View {
    let onAddPhoto: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "camera.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.6))
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                )
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No photos yet!")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Be the first to share a moment from this event")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Share First Photo") {
                onAddPhoto()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(minHeight: 300)
        .vibrantGlassMaterial()
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: EventPhoto
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Photo
                    if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    }
                    
                    // Caption
                    if !photo.caption.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Caption")
                                .font(DesignSystem.Typography.title3)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text(photo.caption)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .glassMaterial()
                    }
                    
                    // Interaction bar
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        Button {
                            // Handle like
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "heart")
                                Text("\(photo.likeCount) Likes")
                            }
                        }
                        .buttonStyle(CompactButtonStyle())
                        
                        Button {
                            // Handle comment
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "bubble.right")
                                Text("\(photo.commentCount) Comments")
                            }
                        }
                        .buttonStyle(CompactButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                .padding(DesignSystem.Spacing.xl)
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Photo Sharing Sheet
struct PhotoSharingSheetView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Photo Sharing Feature")
                    .font(DesignSystem.Typography.title2)
                
                Text("Take or select photos to share with event attendees")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
            .padding()
            .navigationTitle("Share Photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PhotoTimelineView(
        event: Event(
            title: "Community BBQ",
            details: "Join us for a fun afternoon!",
            location: "Central Park",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            hostId: UUID(),
            category: .community
        )
    )
    .environmentObject(SocialAPIService(supabaseService: SupabaseService.shared))
}