import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        Group {
            switch authService.authStatus {
            case .unauthenticated:
                LoginView()
                    .transition(.opacity)
                
            case .authenticating:
                LoadingView(message: "Signing you in...")
                    .transition(.opacity)
                    
            case .emailVerificationRequired(let email):
                EmailVerificationView(email: email)
                    .transition(.opacity)
                
            case .onboarding(let user):
                OnboardingFlowView(user: user)
                    .transition(.slide)
                
            case .authenticated(let user):
                RootTabView()
                    .transition(.slide)
                
            case .error(let message):
                ErrorView(message: message) {
                    Task {
                        await authService.signOut()
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.authStatus)
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle())
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                Text("Try Again")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 48)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct OnboardingFlowView: View {
    let user: User
    @State private var currentStep: OnboardingStep = .userType
    @State private var selectedUserType: UserType?
    
    private enum OnboardingStep {
        case userType
        case profileCompletion
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case .userType:
                UserTypeSelectionView()
                    .onReceive(NotificationCenter.default.publisher(for: .userTypeSelected)) { notification in
                        if let userType = notification.object as? UserType {
                            selectedUserType = userType
                            currentStep = .profileCompletion
                        }
                    }
                
            case .profileCompletion:
                if let userType = selectedUserType {
                    ProfileCompletionView(selectedUserType: userType)
                } else {
                    UserTypeSelectionView()
                }
            }
        }
        .transition(.slide)
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

// Notification extension for onboarding flow
extension Foundation.Notification.Name {
    static let userTypeSelected = Foundation.Notification.Name("userTypeSelected")
}

#Preview {
    RootView()
        .environmentObject(AuthService())
}