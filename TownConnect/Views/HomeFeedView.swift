import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore

    private var feedEvents: [Event] {
        guard let me = userStore.currentUser else { return [] }
        let following = userStore.following.union([me.id])
        return eventStore.events.filter { following.contains($0.hostId) }
    }

    var body: some View {
        NavigationStack {
            List(feedEvents) { event in
                NavigationLink(value: event.id) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title).font(.headline)
                        Text("\(event.location) • \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: UUID.self) { id in
                if let event = eventStore.events.first(where: { $0.id == id }) {
                    EventDetailView(event: event)
                }
            }
        }
    }
}
