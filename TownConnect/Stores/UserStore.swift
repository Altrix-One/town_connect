import Foundation
import SwiftUI
import Supabase

@MainActor
final class UserStore: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var following: Set<UUID> = []
    
    private let supabase = SupabaseService.shared
    private let authService = AuthService()

    func bootstrap(with api: MockAPIService) async {
        // Keep backward compatibility for now
        // This will be replaced when we fully migrate
        await bootstrapWithSupabase()
    }
    
    func bootstrapWithSupabase() async {
        do {
            // Get current user from auth service
            if let authUser = authService.currentUser {
                currentUser = authUser
                
                // Fetch all public users
                let allUsers: [User] = try await supabase.client
                    .from("users")
                    .select()
                    .eq("is_profile_public", value: true)
                    .execute()
                    .value
                
                users = allUsers
                
                // Fetch following relationships
                let follows: [Follow] = try await supabase.client
                    .from("follows")
                    .select()
                    .eq("follower_id", value: authUser.id.uuidString)
                    .execute()
                    .value
                
                following = Set(follows.map { $0.followingId })
            }
        } catch {
            print("Error bootstrapping UserStore: \(error)")
        }
    }

    func follow(userId: UUID, api: MockAPIService? = nil) async {
        guard let me = currentUser else { return }
        
        do {
            try await supabase.client
                .from("follows")
                .insert(Follow(id: UUID(), followerId: me.id, followingId: userId))
                .execute()
            
            following.insert(userId)
        } catch {
            print("Error following user: \(error)")
        }
    }

    func unfollow(userId: UUID, api: MockAPIService? = nil) async {
        guard let me = currentUser else { return }
        
        do {
            try await supabase.client
                .from("follows")
                .delete()
                .eq("follower_id", value: me.id.uuidString)
                .eq("following_id", value: userId.uuidString)
                .execute()
            
            following.remove(userId)
        } catch {
            print("Error unfollowing user: \(error)")
        }
    }

    func updateProfile(_ update: User, api: MockAPIService? = nil) async {
        do {
            let savedUser: User = try await supabase.client
                .from("users")
                .update(update)
                .eq("id", value: update.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            if let idx = users.firstIndex(where: { $0.id == savedUser.id }) { 
                users[idx] = savedUser 
            }
            if currentUser?.id == savedUser.id { 
                currentUser = savedUser 
            }
        } catch {
            print("Error updating user profile: \(error)")
        }
    }
    
    func fetchUsers() async {
        do {
            let allUsers: [User] = try await supabase.client
                .from("users")
                .select()
                .eq("is_profile_public", value: true)
                .execute()
                .value
            
            users = allUsers
        } catch {
            print("Error fetching users: \(error)")
        }
    }
    
    func searchUsers(query: String) async -> [User] {
        do {
            let searchResults: [User] = try await supabase.client
                .from("users")
                .select()
                .eq("is_profile_public", value: true)
                .or("username.ilike.%\(query)%,full_name.ilike.%\(query)%,city.ilike.%\(query)%")
                .execute()
                .value
            
            return searchResults
        } catch {
            print("Error searching users: \(error)")
            return []
        }
    }
    
    func reset() {
        currentUser = nil
        users = []
        following = []
    }
}
