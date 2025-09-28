import Foundation
import SwiftUI

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var query: String = ""

    func filterUsers(_ users: [User]) -> [User] {
        if query.isEmpty { return users }
        return users.filter { $0.username.localizedCaseInsensitiveContains(query) || $0.fullName.localizedCaseInsensitiveContains(query) }
    }

    func filterEvents(_ events: [Event]) -> [Event] {
        if query.isEmpty { return events }
        return events.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.location.localizedCaseInsensitiveContains(query) }
    }
}
