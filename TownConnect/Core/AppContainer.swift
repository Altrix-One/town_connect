import Foundation
import SwiftUI

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let authService = AuthService()
    let api = MockAPIService()
    let userStore = UserStore()
    let eventStore = EventStore()
    let supabaseService = SupabaseService.shared

    private init() {
        setupServices()
    }
    
    private func setupServices() {
        // Bootstrap stores based on auth state
        Task { @MainActor in
            // For development, always bootstrap with both Supabase and MockAPI fallback
            await userStore.bootstrap(with: api)
            await eventStore.bootstrap(with: api, userStore: userStore)
        }
    }
    
    func onAuthStateChange() {
        Task { @MainActor in
            switch authService.authStatus {
            case .authenticated:
                await userStore.bootstrap(with: api)
                await eventStore.bootstrap(with: api, userStore: userStore)
            case .unauthenticated, .error:
                // Clear stores when user signs out
                userStore.reset()
                eventStore.reset()
                // Still bootstrap with mock data for development
                await userStore.bootstrap(with: api)
                await eventStore.bootstrap(with: api, userStore: userStore)
            case .onboarding, .authenticating, .emailVerificationRequired:
                // Wait for authentication to complete
                break
            }
        }
    }
}
