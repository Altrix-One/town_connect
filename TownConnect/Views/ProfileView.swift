import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var authService: AuthService
    @State private var showingEdit = false
    @State private var showingSettings = false
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            if let me = userStore.currentUser {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Header Section
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            // Avatar with status indicator
                            ZStack {
                                AvatarView(data: me.avatarData)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .designSystemShadow(DesignSystem.Shadows.medium)
                                
                                // Online status indicator
                                Circle()
                                    .fill(DesignSystem.Colors.success)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(DesignSystem.Colors.surface, lineWidth: 3)
                                    )
                                    .offset(x: 40, y: -40)
                            }
                            
                            // User Info
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text(me.fullName)
                                    .font(DesignSystem.Typography.title2)
                                    .foregroundColor(DesignSystem.Colors.text)
                                
                                Text("@\(me.username)")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                // User Type Badge
                                UserTypeBadge(userType: me.userType)
                                
                                if !me.bio.isEmpty {
                                    Text(me.bio)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, DesignSystem.Spacing.lg)
                                }
                                
                                // Location if available
                                if let location = me.displayLocation {
                                    HStack(spacing: DesignSystem.Spacing.xs) {
                                        Image(systemName: "location.fill")
                                            .font(.caption)
                                        Text(location)
                                            .font(DesignSystem.Typography.caption)
                                    }
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                            }
                        }
                        
                        // Interests Section
                        if !me.interests.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("Interests")
                                        .font(DesignSystem.Typography.title3)
                                        .foregroundColor(DesignSystem.Colors.text)
                                    Spacer()
                                }
                                
                                ModernChipsView(chips: me.interests)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                        }
                        
                        // Stats Section
                        HStack(spacing: DesignSystem.Spacing.xl) {
                            StatCard(title: "Following", value: "\(userStore.following.count)")
                            StatCard(title: "Permissions", value: "\(me.permissions.count)")
                            StatCard(title: "Events", value: "0") // TODO: Add event count
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        
                        // Action Buttons
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Button("Edit Profile") {
                                showingEdit = true
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            Button("Settings") {
                                showingSettings = true
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            
                            Button("Sign Out") {
                                showingLogoutConfirmation = true
                            }
                            .buttonStyle(DestructiveButtonStyle())
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        
                        Spacer(minLength: DesignSystem.Spacing.huge)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                .background(DesignSystem.Colors.background)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView("Loading profile...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignSystem.Colors.background)
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditProfileView(user: userStore.currentUser!)
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(authService)
        }
        .confirmationDialog(
            "Are you sure you want to sign out?",
            isPresented: $showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task {
                    await authService.signOut()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct AvatarView: View {
    let data: Data?
    var body: some View {
        if let data, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
    }
}

struct ModernChipsView: View {
    let chips: [String]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100, maximum: 150), spacing: DesignSystem.Spacing.sm)
        ], spacing: DesignSystem.Spacing.sm) {
            ForEach(chips, id: \.self) { chip in
                Text(chip)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                                    .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(value)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .cardStyle()
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    @State private var notificationsEnabled = true
    @State private var profileVisible = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Privacy") {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("Profile Visibility")
                        Spacer()
                        Toggle("", isOn: $profileVisible)
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                    }
                }
                
                Section("Account") {
                    Button("Change Password") {
                        // TODO: Implement password change
                    }
                    .foregroundColor(DesignSystem.Colors.text)
                    
                    Button("Delete Account") {
                        // TODO: Implement account deletion
                    }
                    .foregroundColor(DesignSystem.Colors.error)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Show privacy policy
                    }
                    .foregroundColor(DesignSystem.Colors.text)
                    
                    Button("Terms of Service") {
                        // TODO: Show terms
                    }
                    .foregroundColor(DesignSystem.Colors.text)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WrapChips: View {
    let chips: [String]
    var body: some View {
        FlexibleView(data: chips, spacing: 8, alignment: .leading) { item in
            Text(item).padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color("SecondaryGreen").opacity(0.15))
                .foregroundColor(Color("PrimaryBlue"))
                .clipShape(Capsule())
        }
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { row in
                HStack(spacing: spacing) { ForEach(row, id: \.self) { content($0) } }
            }
        }
    }

    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 32
        for item in data {
            let itemWidth: CGFloat = CGFloat(String(describing: item).count * 8 + 24)
            if currentRowWidth + itemWidth > maxWidth {
                rows.append([item])
                currentRowWidth = itemWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += itemWidth + spacing
            }
        }
        return rows
    }
}
