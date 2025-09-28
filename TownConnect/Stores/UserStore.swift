import Foundation
import SwiftUI

@MainActor
final class UserStore: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var following: Set<UUID> = []

    func bootstrap(with api: MockAPIService) async {
        let me = await api.getCurrentUser()
        let all = await api.getAllUsers()
        let f = await api.getFollows(for: me.id)
        self.currentUser = me
        self.users = all
        self.following = Set(f.map { $0.followingId })
    }

    func follow(userId: UUID, api: MockAPIService) async {
        guard let me = currentUser else { return }
        await api.follow(followerId: me.id, followingId: userId)
        following.insert(userId)
    }

    func unfollow(userId: UUID, api: MockAPIService) async {
        guard let me = currentUser else { return }
        await api.unfollow(followerId: me.id, followingId: userId)
        following.remove(userId)
    }

    func updateProfile(_ update: User, api: MockAPIService) async {
        let saved = await api.updateUser(update)
        if let idx = users.firstIndex(where: { $0.id == saved.id }) { users[idx] = saved }
        if currentUser?.id == saved.id { currentUser = saved }
    }
}
