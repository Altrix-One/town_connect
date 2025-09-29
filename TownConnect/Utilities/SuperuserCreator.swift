import Foundation
import Supabase

@MainActor
class SuperuserCreator: ObservableObject {
    @Published var isCreating = false
    @Published var statusMessage = ""
    @Published var isSuccess = false
    
    private let authService = AuthService()
    private let supabaseService = SupabaseService.shared
    
    struct SuperuserInfo {
        let email: String
        let password: String
        let fullName: String
        let username: String
        let city: String
        let state: String
    }
    
    func createSuperuser(_ info: SuperuserInfo) async {
        isCreating = true
        statusMessage = "Creating superuser account..."
        isSuccess = false
        
        do {
            // Step 1: Create Supabase auth user
            statusMessage = "Creating authentication account..."
            let authResponse = try await supabaseService.client.auth.signUp(
                email: info.email,
                password: info.password,
                data: [
                    "full_name": AnyJSON.string(info.fullName),
                    "username": AnyJSON.string(info.username),
                    "user_type": AnyJSON.string("admin")
                ]
            )
            
            let supabaseUser = authResponse.user
            
            // Step 2: Create User profile with admin privileges
            statusMessage = "Setting up admin profile..."
            let adminUser = User(
                id: UUID(uuidString: supabaseUser.id.uuidString)!,
                username: info.username,
                fullName: info.fullName,
                bio: "System Administrator",
                interests: ["Community Management", "Events", "Administration"],
                email: info.email,
                userType: .admin,
                socialProvider: .email,
                isEmailVerified: true, // Auto-verify admin
                isOnboardingComplete: true, // Skip onboarding for admin
                city: info.city,
                state: info.state,
                isProfilePublic: false, // Keep admin profile private
                showEmail: false,
                showPhone: false
            )
            
            // Step 3: Insert user into database
            statusMessage = "Saving admin profile to database..."
            _ = try await supabaseService.createUser(adminUser)
            
            // Step 4: Verify admin permissions
            statusMessage = "Verifying admin permissions..."
            let permissions = adminUser.permissions
            
            if permissions.contains(.systemAdmin) && 
               permissions.contains(.manageUsers) &&
               permissions.contains(.moderateContent) {
                statusMessage = "✅ Superuser created successfully!"
                isSuccess = true
                
                print("🎉 SUPERUSER CREATED SUCCESSFULLY!")
                print("📧 Email: \(info.email)")
                print("👤 Username: \(info.username)")
                print("🏷️ User Type: Administrator")
                print("🔑 Permissions: \(permissions.count) permissions granted")
                print("⚡ Status: Ready to use")
                
            } else {
                throw SuperuserError.permissionVerificationFailed
            }
            
        } catch {
            statusMessage = "❌ Error: \(error.localizedDescription)"
            isSuccess = false
            print("💥 SUPERUSER CREATION FAILED: \(error)")
        }
        
        isCreating = false
    }
    
    // Quick method for command line usage
    static func createQuickSuperuser() async {
        print("🚀 TownConnect Superuser Creator")
        print("================================")
        
        let creator = SuperuserCreator()
        
        // Default superuser info - CHANGE THESE VALUES!
        let superuserInfo = SuperuserInfo(
            email: "admin@townconnect.app",
            password: "TownConnect2024!",
            fullName: "System Administrator",
            username: "admin",
            city: "Default City",
            state: "Default State"
        )
        
        print("📝 Creating superuser with:")
        print("   Email: \(superuserInfo.email)")
        print("   Username: \(superuserInfo.username)")
        print("   Name: \(superuserInfo.fullName)")
        print("")
        
        await creator.createSuperuser(superuserInfo)
        
        if creator.isSuccess {
            print("")
            print("🎯 Next Steps:")
            print("1. Launch the TownConnect app")
            print("2. Sign in with: \(superuserInfo.email)")
            print("3. Use password: \(superuserInfo.password)")
            print("4. You'll have full admin access!")
            print("")
            print("⚠️  IMPORTANT: Change the default password after first login!")
        }
    }
}

enum SuperuserError: LocalizedError {
    case authCreationFailed
    case profileCreationFailed
    case permissionVerificationFailed
    
    var errorDescription: String? {
        switch self {
        case .authCreationFailed:
            return "Failed to create authentication account"
        case .profileCreationFailed:
            return "Failed to create user profile"
        case .permissionVerificationFailed:
            return "Failed to verify admin permissions"
        }
    }
}