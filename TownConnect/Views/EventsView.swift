import SwiftUI

struct EventsView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    @State private var showingCreate = false

    var myEvents: [Event] {
        guard let me = userStore.currentUser else { return [] }
        return eventStore.events.filter { $0.hostId == me.id }
    }

    var body: some View {
        NavigationStack {
            List {
                if let me = userStore.currentUser {
                    Section("My Events") {
                        ForEach(myEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                    Text(event.startDate, style: .date).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    Section("Invites") {
                        ForEach(eventStore.invites) { invite in
                            if let ev = eventStore.events.first(where: { $0.id == invite.eventId }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ev.title)
                                        Text("From: \(userStore.users.first(where: { $0.id == invite.fromUserId })?.fullName ?? "Unknown")").font(.caption)
                                    }
                                    Spacer()
                                    Menu(invite.status.rawValue.capitalized) {
                                        ForEach(RSVPStatus.allCases) { status in
                                            Button(status.rawValue.capitalized) {
                                                Task { await eventStore.rsvp(invite: invite, status: status, api: AppContainer.shared.api) }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreate = true } label: { Image(systemName: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showingCreate) {
                if let me = userStore.currentUser {
                    EnhancedCreateEventView(hostId: me.id)
                        .environmentObject(eventStore)
                        .environmentObject(userStore)
                }
            }
        }
    }
}
