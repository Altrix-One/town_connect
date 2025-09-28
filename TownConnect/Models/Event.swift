import Foundation

enum RSVPStatus: String, Codable, CaseIterable, Identifiable {
    case invited, accepted, declined, maybe
    var id: String { rawValue }
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
}

struct Invite: Identifiable, Codable, Equatable {
    let id: UUID
    let eventId: UUID
    let fromUserId: UUID
    let toUserId: UUID
    var status: RSVPStatus
}
