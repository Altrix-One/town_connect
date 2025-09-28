import Foundation
import SwiftUI

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [Event] = []
    @Published var invites: [Invite] = []

    private let calendar = CalendarService()

    func bootstrap(with api: MockAPIService, userStore: UserStore) async {
        let all = await api.getAllEvents()
        self.events = all.sorted(by: { $0.startDate < $1.startDate })
        if let me = userStore.currentUser {
            self.invites = await api.getInvites(for: me.id)
        }
    }

    func createEvent(title: String, details: String, location: String, start: Date, end: Date, hostId: UUID, api: MockAPIService) async {
        let event = Event(id: UUID(), title: title, details: details, location: location, startDate: start, endDate: end, hostId: hostId, attendeeIds: [hostId], coverImageData: nil)
        let saved = await api.createEvent(event)
        events.append(saved)
        events.sort(by: { $0.startDate < $1.startDate })
    }

    func rsvp(invite: Invite, status: RSVPStatus, api: MockAPIService) async {
        var updated = invite
        updated.status = status
        await api.updateInvite(updated)
        if let idx = invites.firstIndex(where: { $0.id == invite.id }) { invites[idx] = updated }
    }

    func addToCalendar(event: Event) async throws {
        try await calendar.addToCalendar(event: event)
    }
}
