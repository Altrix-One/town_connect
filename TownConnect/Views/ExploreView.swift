import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var eventStore: EventStore
    @State private var query = ""

    var filteredUsers: [User] {
        if query.isEmpty { return userStore.users }
        return userStore.users.filter { $0.username.localizedCaseInsensitiveContains(query) || $0.fullName.localizedCaseInsensitiveContains(query) }
    }

    var filteredEvents: [Event] {
        if query.isEmpty { return eventStore.events }
        return eventStore.events.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.location.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredUsers.isEmpty {
                    Section("Users") {
                        ForEach(filteredUsers) { user in
                            HStack {
                                AvatarView(data: user.avatarData).frame(width: 36, height: 36).clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(user.fullName)
                                    Text("@\(user.username)").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                if let me = userStore.currentUser, user.id != me.id {
                                    if userStore.following.contains(user.id) {
                                        Button("Unfollow") { Task { await userStore.unfollow(userId: user.id, api: AppContainer.shared.api) } }
                                    } else {
                                        Button("Follow") { Task { await userStore.follow(userId: user.id, api: AppContainer.shared.api) } }
                                    }
                                }
                            }
                        }
                    }
                }
                if !filteredEvents.isEmpty {
                    Section("Events") {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                    Text(event.location).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $query)
            .navigationTitle("Explore")
        }
    }
}
