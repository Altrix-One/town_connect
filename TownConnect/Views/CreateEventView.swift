import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.dismiss) private var dismiss

    let hostId: UUID
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date().addingTimeInterval(3600)
    @State private var endDate: Date = Date().addingTimeInterval(7200)

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    TextField("Description", text: $details, axis: .vertical)
                }
                Section("When") {
                    DatePicker("Start", selection: $startDate)
                    DatePicker("End", selection: $endDate)
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Create") { create() }.disabled(title.isEmpty || location.isEmpty) }
            }
        }
    }

    private func create() {
        Task {
            await eventStore.createEvent(title: title, details: details, location: location, start: startDate, end: endDate, hostId: hostId, api: AppContainer.shared.api)
            dismiss()
        }
    }
}
