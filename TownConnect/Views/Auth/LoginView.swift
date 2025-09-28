import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxxl) {
                    // App Logo and Welcome with modern gradient
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .designSystemShadow(DesignSystem.Shadows.medium)
                            
                            Image(systemName: "building.2.crop.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Welcome to TownConnect")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text("Connect with your community")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.huge)
                    
                    // Social Login Buttons with modern design
                    VStack(spacing: DesignSystem.Spacing.md) {
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                Task {
                                    await authService.signInWithApple()
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .designSystemShadow(DesignSystem.Shadows.light)
                        
                        SocialLoginButton(
                            title: "Continue with Google",
                            icon: "globe",
                            backgroundColor: Color(red: 0.26, green: 0.52, blue: 0.96)
                        ) {
                            Task {
                                await authService.signInWithGoogle()
                            }
                        }
                        
                        SocialLoginButton(
                            title: "Continue with Facebook",
                            icon: "f.square.fill",
                            backgroundColor: Color(red: 0.23, green: 0.35, blue: 0.60)
                        ) {
                            Task {
                                await authService.signInWithFacebook()
                            }
                        }
                    }
                    
                    // Modern Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(DesignSystem.Colors.border)
                        Text("or")
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(DesignSystem.Colors.border)
                    }
                    
                    // Modern Email/Password Form
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ModernTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        
                        ModernSecureField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $password
                        )
                        
                        Button("Forgot Password?") {
                            showingForgotPassword = true
                        }
                        .font(DesignSystem.Typography.footnoteMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Button(action: {
                            Task {
                                await authService.signInWithEmail(email, password: password)
                            }
                        }) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                }
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(isLoading: authService.isLoading))
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    }
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            showingRegistration = true
                        }
                        .foregroundColor(.accentColor)
                        .fontWeight(.medium)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            .background(
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.surfaceSecondary.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
            .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
                Button("OK") {
                    authService.errorMessage = nil
                }
            } message: {
                Text(authService.errorMessage ?? "")
            }
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

// MARK: - Supporting Components

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(title)
                    .font(DesignSystem.Typography.buttonMedium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor)
            )
            .foregroundColor(.white)
            .designSystemShadow(DesignSystem.Shadows.light)
        }
    }
}

struct ModernTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.text)
            
            TextField(placeholder, text: $text)
                .font(DesignSystem.Typography.body)
                .padding(DesignSystem.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                )
        }
    }
}

struct ModernSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(DesignSystem.Typography.body)
                } else {
                    TextField(placeholder, text: $text)
                        .font(DesignSystem.Typography.body)
                }
                
                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    LoginView()
}
