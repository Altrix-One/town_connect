import SwiftUI

struct SuperuserCreationView: View {
    @StateObject private var creator = SuperuserCreator()
    @State private var showingConfirmation = false
    @State private var customEmail = "admin@townconnect.app"
    @State private var customPassword = "TownConnect2024!"
    @State private var customUsername = "admin"
    @State private var customFullName = "System Administrator"
    @State private var customCity = "Default City"
    @State private var customState = "Default State"
    @State private var useCustomSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.badge.shield.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Create Superuser")
                        .font(.title)
                        .bold()
                    
                    Text("Create an administrator account with full system access")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Status indicator
                if creator.isCreating {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(creator.statusMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Success/Error message
                if !creator.statusMessage.isEmpty && !creator.isCreating {
                    Text(creator.statusMessage)
                        .font(.subheadline)
                        .foregroundColor(creator.isSuccess ? .green : .red)
                        .padding()
                        .background((creator.isSuccess ? Color.green : Color.red).opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Custom settings toggle
                Toggle("Use Custom Settings", isOn: $useCustomSettings)
                    .padding(.horizontal)
                
                // Custom settings form
                if useCustomSettings {
                    Form {
                        Section("Account Details") {
                            TextField("Email", text: $customEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Password", text: $customPassword)
                            
                            TextField("Username", text: $customUsername)
                                .autocapitalization(.none)
                            
                            TextField("Full Name", text: $customFullName)
                        }
                        
                        Section("Location") {
                            TextField("City", text: $customCity)
                            TextField("State", text: $customState)
                        }
                    }
                    .frame(height: 300)
                }
                
                // Default settings display
                if !useCustomSettings {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Settings:")
                            .font(.headline)
                        
                        HStack {
                            Text("Email:")
                                .bold()
                            Text("admin@townconnect.app")
                        }
                        
                        HStack {
                            Text("Username:")
                                .bold()
                            Text("admin")
                        }
                        
                        HStack {
                            Text("Password:")
                                .bold()
                            Text("TownConnect2024!")
                        }
                        
                        Text("⚠️ Change password after first login!")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Create button
                Button("Create Superuser") {
                    showingConfirmation = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(creator.isCreating ? Color.gray : Color.blue)
                .cornerRadius(12)
                .disabled(creator.isCreating)
                .padding(.horizontal)
                
                // Warning text
                Text("⚠️ This will create an admin account with full system privileges")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
        .alert("Confirm Superuser Creation", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Create", role: .destructive) {
                createSuperuser()
            }
        } message: {
            Text("Are you sure you want to create a superuser account? This will grant full administrative access to the system.")
        }
    }
    
    private func createSuperuser() {
        let info = SuperuserCreator.SuperuserInfo(
            email: useCustomSettings ? customEmail : "admin@townconnect.app",
            password: useCustomSettings ? customPassword : "TownConnect2024!",
            fullName: useCustomSettings ? customFullName : "System Administrator",
            username: useCustomSettings ? customUsername : "admin",
            city: useCustomSettings ? customCity : "Default City",
            state: useCustomSettings ? customState : "Default State"
        )
        
        Task {
            await creator.createSuperuser(info)
        }
    }
}

// Preview for development
#if DEBUG
struct SuperuserCreationView_Previews: PreviewProvider {
    static var previews: some View {
        SuperuserCreationView()
    }
}
#endif