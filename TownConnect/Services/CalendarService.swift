import Foundation
import EventKit

final class CalendarService {
    private let store = EKEventStore()

    func addToCalendar(event: Event) async throws {
        try await store.requestAccess(to: .event)
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.notes = event.details
        ekEvent.location = event.location
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.calendar = store.defaultCalendarForNewEvents
        try store.save(ekEvent, span: .thisEvent)
    }
}
