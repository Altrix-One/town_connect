import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) private var dismiss

    @State var user: User
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var interestsText: String = ""
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        AvatarView(data: user.avatarData).frame(width: 60, height: 60).clipShape(Circle())
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Choose Photo")
                        }
                    }
                }
                Section("Name & Bio") {
                    TextField("Full name", text: $fullName)
                    TextField("Bio", text: $bio, axis: .vertical)
                }
                Section("Interests") {
                    TextField("Comma-separated (e.g. Hiking, Music)", text: $interestsText)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
            }
            .task {
                fullName = user.fullName
                bio = user.bio
                interestsText = user.interests.joined(separator: ", ")
            }
            .onChange(of: selectedItem) { newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self) {
                        user.avatarData = data
                    }
                }
            }
        }
    }

    private func save() {
        user.fullName = fullName
        user.bio = bio
        user.interests = interestsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        Task {
            await userStore.updateProfile(user, api: AppContainer.shared.api)
            dismiss()
        }
    }
}
