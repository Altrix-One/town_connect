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
            // Wait for auth state to be determined
            if case .authenticated(let user) = authService.authStatus {
                await userStore.bootstrapWithSupabase()
                await eventStore.bootstrapWithSupabase(userStore: userStore)
            }
        }
    }
    
    func onAuthStateChange() {
        Task { @MainActor in
            switch authService.authStatus {
            case .authenticated:
                await userStore.bootstrapWithSupabase()
                await eventStore.bootstrapWithSupabase(userStore: userStore)
            case .unauthenticated, .error:
                // Clear stores when user signs out
                userStore.reset()
                eventStore.reset()
            case .onboarding, .authenticating, .emailVerificationRequired:
                // Wait for authentication to complete
                break
            }
        }
    }
}
