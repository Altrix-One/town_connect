import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var draft: User?

    func beginEditing(user: User) {
        draft = user
    }

    func applyEdits(to store: UserStore, api: MockAPIService) async {
        guard let draft else { return }
        await store.updateProfile(draft, api: api)
        self.draft = nil
    }
}
