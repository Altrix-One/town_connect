import Foundation
import Supabase
import AuthenticationServices
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var authStatus: AuthStatus = .unauthenticated
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
        checkCurrentSession()
    }
    
    // MARK: - Authentication State Management
    
    private func setupAuthStateListener() {
        Task {
            for await (event, session) in supabase.client.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        if let session = session {
                            Task {
                                await self.handleSuccessfulAuth(supabaseUser: session.user)
                            }
                        }
                    case .signedOut:
                        self.handleSignOut()
                    case .tokenRefreshed:
                        // Session refreshed, continue as normal
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func checkCurrentSession() {
        Task {
        do {
            let session = try await supabase.client.auth.session
            await handleSuccessfulAuth(supabaseUser: session.user)
        } catch {
                print("No current session: \(error)")
                authStatus = .unauthenticated
            }
        }
    }
    
    private func handleSuccessfulAuth(supabaseUser: Supabase.User) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch or create user profile
            if let existingUser = try await supabase.fetchUser(id: UUID(uuidString: supabaseUser.id.uuidString)!) {
                currentUser = existingUser
                authStatus = existingUser.isOnboardingComplete ? .authenticated(existingUser) : .onboarding(existingUser)
            } else {
                // Create new user profile
                let newUser = User(
                    id: UUID(uuidString: supabaseUser.id.uuidString)!,
                    username: "",
                    fullName: supabaseUser.userMetadata["full_name"] as? String ?? "",
                    email: supabaseUser.email ?? "",
                    isEmailVerified: supabaseUser.emailConfirmedAt != nil
                )
                
                let createdUser = try await supabase.createUser(newUser)
                currentUser = createdUser
                authStatus = .onboarding(createdUser)
            }
        } catch {
            authStatus = .error("Failed to load user profile: \(error.localizedDescription)")
        }
    }
    
    private func handleSignOut() {
        currentUser = nil
        authStatus = .unauthenticated
        errorMessage = nil
    }
    
    // MARK: - Email Authentication
    
    func signInWithEmail(_ email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase.client.auth.signIn(email: email, password: password)
            // Auth state listener will handle the rest
        } catch {
            let errorDescription = error.localizedDescription
            
            // Check if this is an email verification error
            if errorDescription.contains("email not confirmed") || errorDescription.contains("verification") {
                authStatus = .emailVerificationRequired(email)
            } else {
                authStatus = .error("Sign in failed: \(errorDescription)")
                errorMessage = errorDescription
            }
        }
    }
    
    func signUpWithEmail(_ email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await supabase.client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": AnyJSON.string(fullName)]
            )
            
            // Check if email confirmation is required
            if response.user.emailConfirmedAt == nil {
                authStatus = .emailVerificationRequired(email)
            } else {
                // Auto-confirmed, proceed with normal flow
                await handleSuccessfulAuth(supabaseUser: response.user)
            }
        } catch {
            authStatus = .error("Sign up failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Social Authentication
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            // This would need to be implemented with proper Apple Sign In delegate
            // For now, just show that this is where Apple Sign In would happen
            
        } catch {
            authStatus = .error("Apple Sign In failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // TODO: Implement Google Sign In
            // This would use GoogleSignIn SDK
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Google Sign In not implemented yet"])
        } catch {
            authStatus = .error("Google Sign In failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // TODO: Implement Facebook Sign In
            // This would use FacebookLogin SDK
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Facebook Sign In not implemented yet"])
        } catch {
            authStatus = .error("Facebook Sign In failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Management
    
    func updateUserProfile(_ user: User) async {
        guard let currentUser = currentUser else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updatedUser = try await supabase.updateUser(user)
            self.currentUser = updatedUser
            
            if authStatus == .onboarding(currentUser) && updatedUser.isOnboardingComplete {
                authStatus = .authenticated(updatedUser)
            }
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }
    
    func completeOnboarding(userType: UserType, username: String, city: String?, state: String?) async {
        guard var user = currentUser else { return }
        
        user.userType = userType
        user.username = username
        user.city = city
        user.state = state
        user.isOnboardingComplete = true
        user.updatedAt = Date()
        
        await updateUserProfile(user)
    }
    
    // MARK: - Session Management
    
    func signOut() async {
        do {
            try await supabase.client.auth.signOut()
            // Auth state listener will handle the rest
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() async {
        guard currentUser != nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Implement account deletion
            // This would need to clean up user data and delete the auth user
            try await supabase.client.auth.signOut()
        } catch {
            errorMessage = "Account deletion failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase.client.auth.resetPasswordForEmail(email)
            // Show success message about password reset email
        } catch {
            errorMessage = "Password reset failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Email Verification
    
    func resendEmailVerification(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase.client.auth.resend(email: email, type: .signup)
            // Show success message about email sent
        } catch {
            errorMessage = "Failed to resend verification email: \(error.localizedDescription)"
        }
    }
}
