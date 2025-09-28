import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        // Supabase project credentials
        let url = URL(string: "https://silgkbzohsxolcwqzadc.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbGdrYnpvaHN4b2xjd3F6YWRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNzM0MzAsImV4cCI6MjA3NDY0OTQzMH0.pFtQSnep3pZ_kXh6etLEjNFcCu980jRZlx9p7Me8J1s"
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }
    
    // MARK: - Database Tables
    
    // Users table operations
    func fetchUser(id: UUID) async throws -> User? {
        let response: [User] = try await client
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value
        
        return response.first
    }
    
    func updateUser(_ user: User) async throws -> User {
        let response: User = try await client
            .from("users")
            .update(user)
            .eq("id", value: user.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func createUser(_ user: User) async throws -> User {
        let response: User = try await client
            .from("users")
            .insert(user)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // Events table operations
    func fetchEvents() async throws -> [Event] {
        let response: [Event] = try await client
            .from("events")
            .select()
            .execute()
            .value
        
        return response
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        let response: Event = try await client
            .from("events")
            .insert(event)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        let response: Event = try await client
            .from("events")
            .update(event)
            .eq("id", value: event.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func deleteEvent(id: UUID) async throws {
        try await client
            .from("events")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // Follows table operations
    func followUser(followerId: UUID, followingId: UUID) async throws {
        let follow = Follow(id: UUID(), followerId: followerId, followingId: followingId)
        try await client
            .from("follows")
            .insert(follow)
            .execute()
    }
    
    func unfollowUser(followerId: UUID, followingId: UUID) async throws {
        try await client
            .from("follows")
            .delete()
            .eq("follower_id", value: followerId.uuidString)
            .eq("following_id", value: followingId.uuidString)
            .execute()
    }
    
    func fetchFollowing(for userId: UUID) async throws -> [UUID] {
        let response: [Follow] = try await client
            .from("follows")
            .select()
            .eq("follower_id", value: userId.uuidString)
            .execute()
            .value
        
        return response.map { $0.followingId }
    }
    
    // MARK: - Real-time Subscriptions
    
    func subscribeToEvents(callback: @escaping ([Event]) -> Void) -> RealtimeChannelV2? {
        // TODO: Update to new RealtimeV2 API
        return nil
        /*
        return client.channel("events")
            .on("postgres_changes", 
                filter: "public:events:*"
            ) { payload in
                Task {
                    do {
                        let events = try await self.fetchEvents()
                        await MainActor.run {
                            callback(events)
                        }
                    } catch {
                        print("Error fetching events in subscription: \(error)")
                    }
                }
            }
            .subscribe()
        */
    }
    
    func subscribeToUsers(callback: @escaping ([User]) -> Void) -> RealtimeChannelV2? {
        // TODO: Update to new RealtimeV2 API
        return nil
        /*
        return client.channel("users")
            .on("postgres_changes", 
                filter: "public:users:*"
            ) { payload in
                // Handle user updates
            }
            .subscribe()
        */
    }
}