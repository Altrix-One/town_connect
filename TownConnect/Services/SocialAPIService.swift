import Foundation
import UIKit

// MARK: - Social API Service
@MainActor
class SocialAPIService: ObservableObject {
    
    private let supabaseService: SupabaseService
    
    init(supabaseService: SupabaseService) {
        self.supabaseService = supabaseService
    }
    
    // MARK: - Photo Management
    
    func uploadEventPhoto(eventId: UUID, image: UIImage, caption: String) async throws -> EventPhoto {
        // Resize and compress image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SocialAPIError.invalidImage
        }
        
        // In a real implementation, upload to Supabase Storage
        // For now, we'll store locally with a simulated URL
        let photoId = UUID()
        let imageUrl = "event_photos/\(eventId)/\(photoId).jpg" // Simulated path
        
        let photo = EventPhoto(
            id: photoId,
            eventId: eventId,
            userId: getCurrentUserId(),
            caption: caption,
            imageUrl: imageUrl,
            imageData: imageData
        )
        
        // Save to local storage/mock database
        await saveEventPhoto(photo)
        
        return photo
    }
    
    func getEventPhotos(for eventId: UUID) async throws -> [EventPhoto] {
        // In a real implementation, fetch from Supabase
        // For now, return mock data
        return await loadEventPhotos(for: eventId)
    }
    
    func deleteEventPhoto(_ photoId: UUID) async throws {
        // In a real implementation, delete from Supabase and Storage
        await removeEventPhoto(photoId)
    }
    
    // MARK: - Comments
    
    func addComment(to eventId: UUID?, photoId: UUID?, content: String, replyTo: UUID? = nil) async throws -> Comment {
        let comment = Comment(
            eventId: eventId,
            photoId: photoId,
            userId: getCurrentUserId(),
            content: content,
            replyToCommentId: replyTo
        )
        
        await saveComment(comment)
        return comment
    }
    
    func getComments(for eventId: UUID?, photoId: UUID?) async throws -> [Comment] {
        return await loadComments(for: eventId, photoId: photoId)
    }
    
    func deleteComment(_ commentId: UUID) async throws {
        await removeComment(commentId)
    }
    
    // MARK: - Reactions
    
    func addReaction(to eventId: UUID?, photoId: UUID?, commentId: UUID?, type: ReactionType) async throws -> Reaction {
        // Remove existing reaction if any
        await removeExistingReaction(eventId: eventId, photoId: photoId, commentId: commentId)
        
        let reaction = Reaction(
            userId: getCurrentUserId(),
            eventId: eventId,
            photoId: photoId,
            commentId: commentId,
            type: type
        )
        
        await saveReaction(reaction)
        return reaction
    }
    
    func removeReaction(from eventId: UUID?, photoId: UUID?, commentId: UUID?) async throws {
        await removeExistingReaction(eventId: eventId, photoId: photoId, commentId: commentId)
    }
    
    func getReactions(for eventId: UUID?, photoId: UUID?, commentId: UUID?) async throws -> [Reaction] {
        return await loadReactions(for: eventId, photoId: photoId, commentId: commentId)
    }
    
    // MARK: - Follow System
    
    func followUser(_ userId: UUID) async throws {
        let follow = Follow(
            id: UUID(),
            followerId: getCurrentUserId(),
            followingId: userId
        )
        
        await saveFollow(follow)
    }
    
    func unfollowUser(_ userId: UUID) async throws {
        await removeFollow(followerId: getCurrentUserId(), followingId: userId)
    }
    
    func getFollowers(for userId: UUID) async throws -> [UUID] {
        return await loadFollowers(for: userId)
    }
    
    func getFollowing(for userId: UUID) async throws -> [UUID] {
        return await loadFollowing(for: userId)
    }
    
    // MARK: - Notifications
    
    func getNotifications() async throws -> [Notification] {
        return await loadNotifications(for: getCurrentUserId())
    }
    
    func markNotificationAsRead(_ notificationId: UUID) async throws {
        await updateNotificationReadStatus(notificationId, isRead: true)
    }
    
    // MARK: - Private Helper Methods
    
    private func getCurrentUserId() -> UUID {
        // In a real implementation, get from authentication service
        // For now, return a placeholder - this should be replaced with actual auth
        return UUID(uuidString: "87cefeca-16e7-4f0f-a5e6-bd9b58234acd") ?? UUID()
    }
    
    // MARK: - Local Storage Simulation (Replace with Supabase in real implementation)
    
    private func saveEventPhoto(_ photo: EventPhoto) async {
        // Simulate async save to local storage
        MockDataStore.shared.eventPhotos.append(photo)
    }
    
    private func loadEventPhotos(for eventId: UUID) async -> [EventPhoto] {
        return MockDataStore.shared.eventPhotos.filter { $0.eventId == eventId }
    }
    
    private func removeEventPhoto(_ photoId: UUID) async {
        MockDataStore.shared.eventPhotos.removeAll { $0.id == photoId }
    }
    
    private func saveComment(_ comment: Comment) async {
        MockDataStore.shared.comments.append(comment)
    }
    
    private func loadComments(for eventId: UUID?, photoId: UUID?) async -> [Comment] {
        return MockDataStore.shared.comments.filter { 
            $0.eventId == eventId && $0.photoId == photoId 
        }
    }
    
    private func removeComment(_ commentId: UUID) async {
        MockDataStore.shared.comments.removeAll { $0.id == commentId }
    }
    
    private func saveReaction(_ reaction: Reaction) async {
        MockDataStore.shared.reactions.append(reaction)
    }
    
    private func loadReactions(for eventId: UUID?, photoId: UUID?, commentId: UUID?) async -> [Reaction] {
        return MockDataStore.shared.reactions.filter {
            $0.eventId == eventId && $0.photoId == photoId && $0.commentId == commentId
        }
    }
    
    private func removeExistingReaction(eventId: UUID?, photoId: UUID?, commentId: UUID?) async {
        let userId = getCurrentUserId()
        MockDataStore.shared.reactions.removeAll { 
            $0.userId == userId && $0.eventId == eventId && $0.photoId == photoId && $0.commentId == commentId
        }
    }
    
    private func saveFollow(_ follow: Follow) async {
        MockDataStore.shared.follows.append(follow)
    }
    
    private func removeFollow(followerId: UUID, followingId: UUID) async {
        MockDataStore.shared.follows.removeAll { 
            $0.followerId == followerId && $0.followingId == followingId 
        }
    }
    
    private func loadFollowers(for userId: UUID) async -> [UUID] {
        return MockDataStore.shared.follows
            .filter { $0.followingId == userId }
            .map { $0.followerId }
    }
    
    private func loadFollowing(for userId: UUID) async -> [UUID] {
        return MockDataStore.shared.follows
            .filter { $0.followerId == userId }
            .map { $0.followingId }
    }
    
    private func loadNotifications(for userId: UUID) async -> [Notification] {
        return MockDataStore.shared.notifications.filter { $0.userId == userId }
    }
    
    private func updateNotificationReadStatus(_ notificationId: UUID, isRead: Bool) async {
        if let index = MockDataStore.shared.notifications.firstIndex(where: { $0.id == notificationId }) {
            MockDataStore.shared.notifications[index].isRead = isRead
        }
    }
}

// MARK: - Supporting Models

struct Notification: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let fromUserId: UUID
    let type: NotificationType
    let title: String
    let message: String?
    let eventId: UUID?
    let photoId: UUID?
    let commentId: UUID?
    var isRead: Bool
    let createdAt: Date
}

enum NotificationType: String, Codable, CaseIterable {
    case follow, like, comment, eventInvite, eventUpdate, photoTag
}

// MARK: - Mock Data Store
class MockDataStore {
    static let shared = MockDataStore()
    
    var eventPhotos: [EventPhoto] = []
    var comments: [Comment] = []
    var reactions: [Reaction] = []
    var follows: [Follow] = []
    var notifications: [Notification] = []
    
    private init() {}
}

// MARK: - Errors
enum SocialAPIError: LocalizedError {
    case invalidImage
    case networkError
    case unauthorizedAccess
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .networkError:
            return "Network connection error"
        case .unauthorizedAccess:
            return "Unauthorized access"
        case .notFound:
            return "Content not found"
        }
    }
}