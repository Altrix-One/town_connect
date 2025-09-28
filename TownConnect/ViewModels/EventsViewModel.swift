import Foundation
import SwiftUI

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var myEvents: [Event] = []

    func computeMyEvents(from events: [Event], me: User?) {
        guard let me else { myEvents = []; return }
        myEvents = events.filter { $0.hostId == me.id }
    }
}
