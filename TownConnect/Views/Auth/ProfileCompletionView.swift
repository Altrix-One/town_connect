import SwiftUI

struct ProfileCompletionView: View {
    @EnvironmentObject private var authService: AuthService
    let selectedUserType: UserType
    
    @State private var username = ""
    @State private var city = ""
    @State private var state = ""
    @State private var interests: [String] = []
    @State private var newInterest = ""
    
    private let availableInterests = [
        "Community Events", "Local Business", "Sports", "Arts & Culture",
        "Food & Dining", "Health & Wellness", "Education", "Environment",
        "Technology", "Music", "Family Activities", "Volunteering"
    ]
    
    private var isFormValid: Bool {
        !username.isEmpty && !city.isEmpty && !state.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Complete Your Profile")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Help your neighbors get to know you better")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Choose a unique username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 12) {
                                TextField("City", text: $city)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("State", text: $state)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 100)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Select topics you're interested in (optional)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120))
                            ], spacing: 8) {
                                ForEach(availableInterests, id: \.self) { interest in
                                    InterestChip(
                                        text: interest,
                                        isSelected: interests.contains(interest)
                                    ) {
                                        if interests.contains(interest) {
                                            interests.removeAll { $0 == interest }
                                        } else {
                                            interests.append(interest)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !interests.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Selected Interests")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(interests, id: \.self) { interest in
                                            Text(interest)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.accentColor.opacity(0.1))
                                                .foregroundColor(.accentColor)
                                                .cornerRadius(16)
                                        }
                                    }
                                    .padding(.horizontal, 1)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await authService.completeOnboarding(
                                userType: selectedUserType,
                                username: username,
                                city: city.isEmpty ? nil : city,
                                state: state.isEmpty ? nil : state
                            )
                            
                            if var user = authService.currentUser {
                                user.interests = interests
                                await authService.updateUserProfile(user)
                            }
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete Setup")
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
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Profile Setup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
    }
}

struct InterestChip: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.accentColor : Color(UIColor.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileCompletionView(selectedUserType: .resident)
        .environmentObject(AuthService())
}