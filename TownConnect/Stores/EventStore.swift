import Foundation
import SwiftUI
import Supabase

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [Event] = []
    @Published var invites: [Invite] = []

    private let calendar = CalendarService()
    private let supabase = SupabaseService.shared
    private let authService = AuthService()

    func bootstrap(with api: MockAPIService, userStore: UserStore) async {
        // Keep backward compatibility for now
        // This will be replaced when we fully migrate
        await bootstrapWithSupabase(userStore: userStore)
    }
    
    func bootstrapWithSupabase(userStore: UserStore) async {
        do {
            // Fetch all public events
            let allEvents: [Event] = try await supabase.client
                .from("events")
                .select()
                .eq("is_public", value: true)
                .order("start_date", ascending: true)
                .execute()
                .value
            
            events = allEvents
            
            // Fetch invites for current user
            if let currentUser = userStore.currentUser {
                let userInvites: [Invite] = try await supabase.client
                    .from("invites")
                    .select()
                    .eq("invitee_id", value: currentUser.id.uuidString)
                    .execute()
                    .value
                
                invites = userInvites
            }
        } catch {
            print("Error bootstrapping EventStore: \(error)")
        }
    }

    func createEvent(title: String, details: String, location: String, start: Date, end: Date, hostId: UUID, api: MockAPIService? = nil) async {
        let event = Event(
            id: UUID(),
            title: title,
            details: details,
            location: location,
            startDate: start,
            endDate: end,
            hostId: hostId,
            attendeeIds: [hostId],
            coverImageData: nil
        )
        
        do {
            let savedEvent: Event = try await supabase.client
                .from("events")
                .insert(event)
                .select()
                .single()
                .execute()
                .value
            
            events.append(savedEvent)
            events.sort(by: { $0.startDate < $1.startDate })
        } catch {
            print("Error creating event: \(error)")
        }
    }
    
    func updateEvent(_ event: Event) async {
        do {
            let updatedEvent: Event = try await supabase.client
                .from("events")
                .update(event)
                .eq("id", value: event.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            if let idx = events.firstIndex(where: { $0.id == event.id }) {
                events[idx] = updatedEvent
            }
        } catch {
            print("Error updating event: \(error)")
        }
    }
    
    func deleteEvent(_ event: Event) async {
        do {
            try await supabase.client
                .from("events")
                .delete()
                .eq("id", value: event.id.uuidString)
                .execute()
            
            events.removeAll { $0.id == event.id }
        } catch {
            print("Error deleting event: \(error)")
        }
    }

    func rsvp(invite: Invite, status: RSVPStatus, api: MockAPIService? = nil) async {
        var updated = invite
        updated.status = status
        
        do {
            let updatedInvite: Invite = try await supabase.client
                .from("invites")
                .update(updated)
                .eq("id", value: invite.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            if let idx = invites.firstIndex(where: { $0.id == invite.id }) {
                invites[idx] = updatedInvite
            }
            
            // If accepted, add to event attendance
            if status == .accepted {
                await addEventAttendance(eventId: invite.eventId, userId: invite.toUserId)
            }
        } catch {
            print("Error updating RSVP: \(error)")
        }
    }
    
    func addEventAttendance(eventId: UUID, userId: UUID) async {
        do {
            // Create attendance record
            try await supabase.client
                .from("event_attendance")
                .insert([
                    "event_id": eventId.uuidString,
                    "user_id": userId.uuidString,
                    "status": "accepted"
                ])
                .execute()
            
            // Update event attendee_ids array
            if let eventIdx = events.firstIndex(where: { $0.id == eventId }) {
                var updatedEvent = events[eventIdx]
                if !updatedEvent.attendeeIds.contains(userId) {
                    updatedEvent.attendeeIds.append(userId)
                    await updateEvent(updatedEvent)
                }
            }
        } catch {
            print("Error adding event attendance: \(error)")
        }
    }
    
    func fetchEventsForUser(_ userId: UUID) async -> [Event] {
        do {
            let userEvents: [Event] = try await supabase.client
                .from("events")
                .select()
                .eq("host_id", value: userId.uuidString)
                .order("start_date", ascending: true)
                .execute()
                .value
            
            return userEvents
        } catch {
            print("Error fetching user events: \(error)")
            return []
        }
    }
    
    func searchEvents(query: String) async -> [Event] {
        do {
            let searchResults: [Event] = try await supabase.client
                .from("events")
                .select()
                .eq("is_public", value: true)
                .or("title.ilike.%\(query)%,details.ilike.%\(query)%,location.ilike.%\(query)%")
                .order("start_date", ascending: true)
                .execute()
                .value
            
            return searchResults
        } catch {
            print("Error searching events: \(error)")
            return []
        }
    }

    func addToCalendar(event: Event) async throws {
        try await calendar.addToCalendar(event: event)
    }
    
    func reset() {
        events = []
        invites = []
    }
}
