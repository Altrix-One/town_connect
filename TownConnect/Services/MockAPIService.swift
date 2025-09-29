import Foundation

actor MockAPIService {
    // In-memory stores
    private var users: [User] = []
    private var events: [Event] = []
    private var follows: [Follow] = []
    private var invites: [Invite] = []
    private var reactions: [Reaction] = []
    private var comments: [Comment] = []
    private var eventPhotos: [EventPhoto] = []

    init() {
        let u1 = User(id: UUID(), username: "jay", fullName: "Jay Patel", bio: "Explorer of local events", interests: ["Hiking", "Music", "Tech"], avatarData: nil)
        let u2 = User(id: UUID(), username: "sam", fullName: "Sam Lee", bio: "Foodie & gamer", interests: ["Food", "Games"], avatarData: nil)
        let u3 = User(id: UUID(), username: "mia", fullName: "Mia Chen", bio: "Art & culture fan", interests: ["Art", "Culture"], avatarData: nil)
        users = [u1, u2, u3]
        follows = [Follow(id: UUID(), followerId: u1.id, followingId: u2.id)]

        let e1 = Event(id: UUID(), title: "Saturday Hike", details: "Morning hike up Pine Trail.", location: "Pine Trailhead", startDate: Date().addingTimeInterval(60*60*24), endDate: Date().addingTimeInterval(60*60*26), hostId: u2.id, attendeeIds: [u1.id], coverImageData: nil)
        let e2 = Event(id: UUID(), title: "Board Game Night", details: "Bring your favorite games!", location: "Community Center Room B", startDate: Date().addingTimeInterval(60*60*72), endDate: Date().addingTimeInterval(60*60*76), hostId: u3.id, attendeeIds: [], coverImageData: nil)
        events = [e1, e2]
        invites = [Invite(id: UUID(), eventId: e2.id, fromUserId: u3.id, toUserId: u1.id, status: .invited)]
    }

    // Users
    func getCurrentUser() async -> User {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return users[0]
    }

    func getAllUsers() async -> [User] {
        try? await Task.sleep(nanoseconds: 150_000_000)
        return users
    }

    func updateUser(_ user: User) async -> User {
        try? await Task.sleep(nanoseconds: 150_000_000)
        if let idx = users.firstIndex(where: { $0.id == user.id }) { users[idx] = user }
        return user
    }

    // Follows
    func getFollows(for userId: UUID) async -> [Follow] {
        follows.filter { $0.followerId == userId }
    }

    func follow(followerId: UUID, followingId: UUID) async {
        guard !follows.contains(where: { $0.followerId == followerId && $0.followingId == followingId }) else { return }
        follows.append(Follow(id: UUID(), followerId: followerId, followingId: followingId))
    }

    func unfollow(followerId: UUID, followingId: UUID) async {
        follows.removeAll(where: { $0.followerId == followerId && $0.followingId == followingId })
    }

    // Events
    func getAllEvents() async -> [Event] { events }

    func createEvent(_ event: Event) async -> Event {
        events.append(event)
        return event
    }

    func updateEvent(_ event: Event) async -> Event {
        if let idx = events.firstIndex(where: { $0.id == event.id }) { events[idx] = event }
        return event
    }

    // Invites
    func getInvites(for userId: UUID) async -> [Invite] {
        invites.filter { $0.toUserId == userId }
    }

    func sendInvite(_ invite: Invite) async {
        invites.append(invite)
    }

    func updateInvite(_ invite: Invite) async {
        if let idx = invites.firstIndex(where: { $0.id == invite.id }) { invites[idx] = invite }
    }
    
    // RSVP & Attendance
    func rsvpToEvent(eventId: UUID, userId: UUID, status: RSVPStatus) async {
        // Update or create invite
        if let existingInviteIndex = invites.firstIndex(where: { $0.eventId == eventId && $0.toUserId == userId }) {
            invites[existingInviteIndex].status = status
            invites[existingInviteIndex].updatedAt = Date()
        } else {
            // Create new invite/RSVP
            let invite = Invite(
                eventId: eventId,
                fromUserId: events.first(where: { $0.id == eventId })?.hostId ?? UUID(),
                toUserId: userId,
                status: status
            )
            invites.append(invite)
        }
        
        // Update event attendee list
        if let eventIndex = events.firstIndex(where: { $0.id == eventId }) {
            var event = events[eventIndex]
            
            if status == .accepted && !event.attendeeIds.contains(userId) {
                event.attendeeIds.append(userId)
            } else if status != .accepted && event.attendeeIds.contains(userId) {
                event.attendeeIds.removeAll { $0 == userId }
            }
            
            events[eventIndex] = event
        }
    }
    
    func getEventAttendees(eventId: UUID) async -> [User] {
        guard let event = events.first(where: { $0.id == eventId }) else { return [] }
        return users.filter { event.attendeeIds.contains($0.id) }
    }
    
    func getUserRSVPStatus(eventId: UUID, userId: UUID) async -> RSVPStatus {
        return invites.first { $0.eventId == eventId && $0.toUserId == userId }?.status ?? .invited
    }
    
    // Reactions
    func addReaction(_ reaction: Reaction) async {
        // Remove any existing reaction from this user for this item
        reactions.removeAll { $0.userId == reaction.userId && $0.eventId == reaction.eventId && $0.photoId == reaction.photoId && $0.commentId == reaction.commentId }
        reactions.append(reaction)
    }
    
    func removeReaction(userId: UUID, eventId: UUID? = nil, photoId: UUID? = nil, commentId: UUID? = nil) async {
        reactions.removeAll { $0.userId == userId && $0.eventId == eventId && $0.photoId == photoId && $0.commentId == commentId }
    }
    
    func getReactions(for eventId: UUID) async -> [Reaction] {
        return reactions.filter { $0.eventId == eventId }
    }
    
    // Comments
    func addComment(_ comment: Comment) async {
        comments.append(comment)
    }
    
    func getComments(for eventId: UUID) async -> [Comment] {
        return comments.filter { $0.eventId == eventId }.sorted { $0.createdAt < $1.createdAt }
    }
    
    // Event Photos
    func uploadEventPhoto(_ photo: EventPhoto) async {
        eventPhotos.append(photo)
        
        // Update user photo count
        if let userIndex = users.firstIndex(where: { $0.id == photo.userId }) {
            users[userIndex].photoCount += 1
        }
    }
    
    func getEventPhotos(for eventId: UUID) async -> [EventPhoto] {
        return eventPhotos.filter { $0.eventId == eventId && $0.isVisible }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getUserPhotos(for userId: UUID) async -> [EventPhoto] {
        return eventPhotos.filter { $0.userId == userId && $0.isVisible }.sorted { $0.createdAt > $1.createdAt }
    }
}
