import Foundation

enum RSVPStatus: String, Codable, CaseIterable, Identifiable {
    case invited, accepted, declined, maybe
    var id: String { rawValue }
}

enum EventStatus: String, Codable, CaseIterable {
    case upcoming, ongoing, completed, cancelled
}

enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case community, sports, culture, food, business, education, family, music, art, social
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .community: return "Community"
        case .sports: return "Sports"
        case .culture: return "Culture"
        case .food: return "Food & Dining"
        case .business: return "Business"
        case .education: return "Education"
        case .family: return "Family"
        case .music: return "Music"
        case .art: return "Art"
        case .social: return "Social"
        }
    }
    
    var icon: String {
        switch self {
        case .community: return "building.2.fill"
        case .sports: return "sportscourt.fill"
        case .culture: return "theatermasks.fill"
        case .food: return "fork.knife"
        case .business: return "briefcase.fill"
        case .education: return "book.fill"
        case .family: return "house.fill"
        case .music: return "music.note"
        case .art: return "paintpalette.fill"
        case .social: return "person.3.fill"
        }
    }
}

struct Event: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var location: String
    var startDate: Date
    var endDate: Date
    var hostId: UUID
    var attendeeIds: [UUID]
    var coverImageData: Data?
    
    // Enhanced social features
    var category: EventCategory
    var status: EventStatus
    var isPublic: Bool
    var maxAttendees: Int?
    var tags: [String]
    var photoIds: [UUID] // References to EventPhoto objects
    var likeCount: Int
    var commentCount: Int
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        location: String,
        startDate: Date,
        endDate: Date,
        hostId: UUID,
        attendeeIds: [UUID] = [],
        coverImageData: Data? = nil,
        category: EventCategory = .community,
        status: EventStatus = .upcoming,
        isPublic: Bool = true,
        maxAttendees: Int? = nil,
        tags: [String] = [],
        photoIds: [UUID] = [],
        likeCount: Int = 0,
        commentCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.hostId = hostId
        self.attendeeIds = attendeeIds
        self.coverImageData = coverImageData
        self.category = category
        self.status = status
        self.isPublic = isPublic
        self.maxAttendees = maxAttendees
        self.tags = tags
        self.photoIds = photoIds
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Codable Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case details
        case location
        case startDate = "start_date"
        case endDate = "end_date"
        case hostId = "host_id"
        case attendeeIds = "attendee_ids"
        case coverImageData = "cover_image_data"
        case category
        case status
        case isPublic = "is_public"
        case maxAttendees = "max_attendees"
        case tags
        case photoIds = "photo_ids"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Event Photo Model
struct EventPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    var caption: String
    var imageUrl: String? // Supabase storage URL
    var imageData: Data? // Local cache
    var likeCount: Int
    var commentCount: Int
    var isVisible: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        eventId: UUID,
        userId: UUID,
        caption: String = "",
        imageUrl: String? = nil,
        imageData: Data? = nil,
        likeCount: Int = 0,
        commentCount: Int = 0,
        isVisible: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.caption = caption
        self.imageUrl = imageUrl
        self.imageData = imageData
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isVisible = isVisible
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Codable Keys
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case caption
        case imageUrl = "image_url"
        case imageData = "image_data"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isVisible = "is_visible"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Comment Model
struct Comment: Identifiable, Codable, Equatable {
    let id: UUID
    let eventId: UUID?
    let photoId: UUID?
    let userId: UUID
    var content: String
    var likeCount: Int
    var replyToCommentId: UUID?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        eventId: UUID? = nil,
        photoId: UUID? = nil,
        userId: UUID,
        content: String,
        likeCount: Int = 0,
        replyToCommentId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.photoId = photoId
        self.userId = userId
        self.content = content
        self.likeCount = likeCount
        self.replyToCommentId = replyToCommentId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Like/Reaction Model
enum ReactionType: String, Codable, CaseIterable {
    case like, love, laugh, wow, sad, angry
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .love: return "❤️"
        case .laugh: return "😂"
        case .wow: return "😮"
        case .sad: return "😢"
        case .angry: return "😠"
        }
    }
}

struct Reaction: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let eventId: UUID?
    let photoId: UUID?
    let commentId: UUID?
    var type: ReactionType
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        eventId: UUID? = nil,
        photoId: UUID? = nil,
        commentId: UUID? = nil,
        type: ReactionType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.eventId = eventId
        self.photoId = photoId
        self.commentId = commentId
        self.type = type
        self.createdAt = createdAt
    }
}

struct Invite: Identifiable, Codable, Equatable {
    let id: UUID
    let eventId: UUID
    let fromUserId: UUID
    let toUserId: UUID
    var status: RSVPStatus
    var message: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        eventId: UUID,
        fromUserId: UUID,
        toUserId: UUID,
        status: RSVPStatus = .invited,
        message: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
