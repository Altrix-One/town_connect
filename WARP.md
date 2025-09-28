# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project: TownConnect (iOS, SwiftUI, iOS 16+)

Development commands

- Open in Xcode (recommended during active development):
  
  ```bash
  open TownConnect.xcodeproj
  ```

- Build with xcodebuild (Debug, iOS Simulator example):
  
  ```bash
  xcodebuild -project TownConnect.xcodeproj \
    -scheme TownConnect \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    build
  ```

- Clean build artifacts:
  
  ```bash
  xcodebuild clean -project TownConnect.xcodeproj -scheme TownConnect
  ```

- Run tests:
  
  Tests are configured with the target: TownConnectTests. Run all tests with:
  
  ```bash
  xcodebuild -project TownConnect.xcodeproj \
    -scheme TownConnect \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    test
  ```

- Run a single test:
  
  ```bash
  xcodebuild -project TownConnect.xcodeproj \
    -scheme TownConnect \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -only-testing:TownConnectTests/MockAPIServiceTests/testSeededUsersContainJay \
    test
  ```

- Regenerate the Xcode project from project.yml (only if you modify project.yml):
  
  ```bash
  xcodegen generate
  ```

- List available simulators (pick a valid name for -destination):
  
  ```bash
  xcrun simctl list devices available
  ```

Notes on linting/formatting

- No SwiftLint/SwiftFormat configuration detected. If you introduce them, add the configs (e.g., .swiftlint.yml) and surface the relevant commands here.

Big-picture architecture

- App entry and environment setup
  - TownConnectApp is the @main entry point. It presents RootTabView and injects shared state via environment objects from a singleton container.
  - AppContainer is a simple service locator that constructs and shares:
    - MockAPIService (actor, in-memory data + async APIs)
    - UserStore (ObservableObject, @MainActor)
    - EventStore (ObservableObject, @MainActor)
  - On init, AppContainer bootstraps UserStore and EventStore asynchronously with the MockAPIService.

- State and domain model
  - Models: User, Event, Follow, Invite, RSVPStatus. All are Codable and Identifiable; Event/Invite capture scheduling and RSVP; Follow captures user relationships.
  - Stores (application state):
    - UserStore: holds current user, all users, and following set. Provides async actions (follow/unfollow/updateProfile) that call MockAPIService and update @Published state.
    - EventStore: holds events and invites; provides createEvent, rsvp, and addToCalendar (delegates to CalendarService). Maintains sorted events.

- Services
  - MockAPIService (actor): seeds in-memory Users/Events/Follows/Invites and provides async methods for fetching and mutating them. Simulates network latency with small Task.sleep calls.
  - CalendarService: wraps EventKit to add an Event to the user’s calendar (requesting access as needed). Info.plist includes NSCalendarsUsageDescription.

- UI composition (SwiftUI)
  - RootTabView defines four tabs mapping to the main features: HomeFeedView, ExploreView, EventsView, ProfileView. The app tint uses color assets (e.g., "PrimaryBlue").
  - Views consume shared state via @EnvironmentObject (UserStore, EventStore).
    - HomeFeedView: Lists events from followed users (and self), with navigation to EventDetailView.
    - ExploreView: Simple search over users and events.
    - EventsView: Shows "My Events" and "Invites"; presents CreateEventView to add new events.
    - ProfileView: Shows current user, allows edit via EditProfileView (photo selection with PhotosPicker). Info.plist includes NSPhotoLibraryUsageDescription.
    - EventDetailView: Shows details; adds to calendar via EventStore → CalendarService with user feedback.
  - ViewModels exist (FeedViewModel, ExploreViewModel, EventsViewModel, ProfileViewModel) for organizing logic; some screens currently compute derived state inline, while the view model types provide a path to extract/centralize logic as needed.

Project configuration (project.yml)

- Name: TownConnect; iOS deployment target: 16.0; Swift version: 5.9.
- Target: TownConnect (iOS application), bundle id: app.townconnect, device family: iPhone and iPad.
- Sources path: TownConnect (contains App, Core, Models, Services, Stores, ViewModels, Views, Resources).
- Scheme: includes test target TownConnectTests.

Operational considerations

- Permissions: Adding to calendar and selecting photos require user permission prompts defined in Info.plist.
- Choosing a simulator name: The destination must use a simulator that exists locally. Use the list command above to pick a valid device name and OS.
