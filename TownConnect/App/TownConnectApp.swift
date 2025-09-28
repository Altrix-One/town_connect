import SwiftUI

@main
struct TownConnectApp: App {
    @StateObject private var authService = AppContainer.shared.authService
    private let container = AppContainer.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(container.userStore)
                .environmentObject(container.eventStore)
                .onChange(of: authService.authStatus) { _ in
                    container.onAuthStateChange()
                }
        }
    }
}
