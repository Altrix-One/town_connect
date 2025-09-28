import SwiftUI

struct UserTypeSelectionView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var selectedUserType: UserType?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Choose Your Role")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Select the option that best describes you in the community")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(UserType.allCases.filter { $0 != .admin }, id: \.self) { userType in
                        UserTypeCard(
                            userType: userType,
                            isSelected: selectedUserType == userType
                        ) {
                            selectedUserType = userType
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    guard let userType = selectedUserType else { return }
                    // Navigate to profile completion
                    // This would typically use navigation
                }) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(selectedUserType != nil ? Color.accentColor : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedUserType == nil)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .navigationTitle("Welcome!")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
    }
}

struct UserTypeCard: View {
    let userType: UserType
    let isSelected: Bool
    let onTap: () -> Void
    
    private var icon: String {
        switch userType {
        case .resident:
            return "house.fill"
        case .businessOwner:
            return "briefcase.fill"
        case .eventOrganizer:
            return "calendar.badge.plus"
        case .communityLeader:
            return "crown.fill"
        case .admin:
            return "gear.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                VStack(spacing: 8) {
                    Text(userType.displayName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(userType.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(20)
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UserTypeSelectionView()
        .environmentObject(AuthService())
}