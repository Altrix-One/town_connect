import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var fullName: String
    var bio: String
    var interests: [String]
    var avatarData: Data? // simple local storage
}
