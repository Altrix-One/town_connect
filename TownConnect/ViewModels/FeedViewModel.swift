import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []
    private let userStore: UserStore
    private let eventStore: EventStore

    init(userStore: UserStore, eventStore: EventStore) {
        self.userStore = userStore
        self.eventStore = eventStore
        self.events = []
        Task { [weak self] in await self?.reload() }
    }

    func reload() async {
        guard let me = userStore.currentUser else { return }
        let following = userStore.following.union([me.id])
        self.events = eventStore.events.filter { following.contains($0.hostId) }
    }
}
