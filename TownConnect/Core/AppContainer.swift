import Foundation
import SwiftUI

final class AppContainer {
    static let shared = AppContainer()

    let api = MockAPIService()
    let userStore = UserStore()
    let eventStore = EventStore()

    private init() {
        Task { @MainActor in
            await userStore.bootstrap(with: api)
            await eventStore.bootstrap(with: api, userStore: userStore)
        }
    }
}
