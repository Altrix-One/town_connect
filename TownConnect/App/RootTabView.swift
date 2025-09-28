import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                        Text("Explore")
                    }
                }
                .tag(1)
            
            EventsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "calendar.circle.fill" : "calendar.circle")
                        Text("Events")
                    }
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                        Text("Profile")
                    }
                }
                .tag(3)
        }
        .tint(Color("PrimaryBlue"))
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Set tab bar item colors
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("PrimaryBlue"))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color("PrimaryBlue")),
                .font: UIFont.systemFont(ofSize: 11, weight: .medium)
            ]
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 11, weight: .regular)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppContainer.shared.userStore)
        .environmentObject(AppContainer.shared.eventStore)
}
