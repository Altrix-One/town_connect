import SwiftUI

struct EmailVerificationView: View {
    let email: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    @State private var showResendSuccess = false
    @State private var isResending = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Check Your Email")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 8) {
                        Text("We've sent a verification link to:")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text(email)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Text("Please check your email and click the verification link to activate your account. Once verified, you can sign in to TownConnect.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    if showResendSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Verification email sent!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            isResending = true
                            await authService.resendEmailVerification(email: email)
                            isResending = false
                            if authService.errorMessage == nil {
                                showResendSuccess = true
                                // Hide success message after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showResendSuccess = false
                                }
                            }
                        }
                    }) {
                        HStack {
                            if isResending {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Resend Verification Email")
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isResending)
                    
                    Button("I'll verify later") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Didn't receive the email?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Check your spam folder or contact support if you continue to have issues.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationTitle("Email Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
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
        }
    }
}

#Preview {
    EmailVerificationView(email: "user@example.com")
}