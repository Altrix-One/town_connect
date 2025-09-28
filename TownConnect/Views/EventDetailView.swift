import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var userStore: UserStore

    let event: Event
    @State private var showingCalendarAlert = false
    @State private var calendarError: String?

    var host: User? { userStore.users.first(where: { $0.id == event.hostId }) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    Rectangle().fill(Color("PrimaryBlue").opacity(0.15)).frame(height: 180).cornerRadius(12)
                    VStack(alignment: .leading) {
                        Text(event.title).font(.title).bold()
                        Text(host?.fullName ?? "").font(.subheadline).foregroundColor(.secondary)
                    }.padding()
                }
                VStack(alignment: .leading, spacing: 8) {
                    Label(event.location, systemImage: "mappin.circle")
                    Label("\(event.startDate.formatted(date: .abbreviated, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))", systemImage: "calendar")
                    Text(event.details)
                }
                HStack {
                    Button("Add to Calendar") { addToCalendar() }
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Event")
        .alert("Calendar", isPresented: $showingCalendarAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(calendarError ?? "Added to Calendar")
        }
    }

    private func addToCalendar() {
        Task {
            do { try await eventStore.addToCalendar(event: event); calendarError = nil } catch { calendarError = error.localizedDescription }
            showingCalendarAlert = true
        }
    }
}
