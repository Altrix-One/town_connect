import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ExploreView()
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }
            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(Color("PrimaryBlue"))
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppContainer.shared.userStore)
        .environmentObject(AppContainer.shared.eventStore)
}
