import Foundation

struct Follow: Identifiable, Codable, Equatable {
    let id: UUID
    let followerId: UUID
    let followingId: UUID
}
