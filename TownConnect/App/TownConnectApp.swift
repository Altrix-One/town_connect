import SwiftUI

@main
struct TownConnectApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(AppContainer.shared.userStore)
                .environmentObject(AppContainer.shared.eventStore)
        }
    }
}
