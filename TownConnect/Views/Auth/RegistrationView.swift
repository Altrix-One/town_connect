import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false
    @State private var showEmailVerification = false
    @State private var registrationEmail = ""
    
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        acceptedTerms
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Join TownConnect")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Create your account to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Button(action: {
                                    acceptedTerms.toggle()
                                }) {
                                    Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(acceptedTerms ? .accentColor : .gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("I agree to the Terms of Service and Privacy Policy")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Button("Terms of Service") {
                                            // TODO: Open terms of service
                                        }
                                        .foregroundColor(.accentColor)
                                        .font(.footnote)
                                        
                                        Text("and")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                        
                                        Button("Privacy Policy") {
                                            // TODO: Open privacy policy
                                        }
                                        .foregroundColor(.accentColor)
                                        .font(.footnote)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            Task {
                                await authService.signUpWithEmail(email, password: password, fullName: fullName)
                                
                                switch authService.authStatus {
                                case .emailVerificationRequired(let verificationEmail):
                                    registrationEmail = verificationEmail
                                    showEmailVerification = true
                                case .onboarding, .authenticated:
                                    // Email was auto-confirmed, dismiss this view
                                    dismiss()
                                case .error:
                                    // Error will be shown via alert
                                    break
                                default:
                                    break
                                }
                            }
                        }) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(!isFormValid || authService.isLoading)
                    }
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign In") {
                            dismiss()
                        }
                        .foregroundColor(.accentColor)
                        .fontWeight(.medium)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
                Button("OK") {
                    authService.errorMessage = nil
                }
            } message: {
                Text(authService.errorMessage ?? "")
            }
            .sheet(isPresented: $showEmailVerification) {
                EmailVerificationView(email: registrationEmail)
            }
        }
    }
}

#Preview {
    RegistrationView()
}