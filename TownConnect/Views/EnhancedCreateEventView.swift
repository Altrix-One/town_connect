import SwiftUI
import MapKit
import PhotosUI

struct EnhancedCreateEventView: View {
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.dismiss) private var dismiss
    
    let hostId: UUID
    
    // Basic event info
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date().addingTimeInterval(3600)
    @State private var endDate: Date = Date().addingTimeInterval(7200)
    @State private var category: EventCategory = .community
    @State private var maxAttendees: String = ""
    @State private var tags: String = ""
    
    // Photo upload
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var isUploadingPhoto = false
    
    // Map integration
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingMapPicker = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // UI states
    @State private var currentStep = 0
    @State private var isCreating = false
    
    private let steps = ["Details", "Photo", "Location", "Review"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Magical gradient background
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primaryLight.opacity(0.1),
                        DesignSystem.Colors.accent.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Progress indicator
                        ProgressIndicatorView(currentStep: currentStep, totalSteps: steps.count)
                            .padding(.top, DesignSystem.Spacing.lg)
                        
                        // Step content
                        Group {
                            switch currentStep {
                            case 0:
                                BasicDetailsStep(
                                    title: $title,
                                    details: $details,
                                    category: $category,
                                    startDate: $startDate,
                                    endDate: $endDate,
                                    maxAttendees: $maxAttendees,
                                    tags: $tags
                                )
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            case 1:
                                PhotoSelectionStep(
                                    selectedPhotoItem: $selectedPhotoItem,
                                    selectedPhotoData: $selectedPhotoData,
                                    isUploadingPhoto: $isUploadingPhoto
                                )
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            case 2:
                                LocationSelectionStep(
                                    location: $location,
                                    selectedLocation: $selectedLocation,
                                    mapRegion: $mapRegion,
                                    showingMapPicker: $showingMapPicker
                                )
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            case 3:
                                ReviewStep(
                                    title: title,
                                    details: details,
                                    location: location,
                                    startDate: startDate,
                                    endDate: endDate,
                                    category: category,
                                    selectedPhotoData: selectedPhotoData,
                                    tags: tags.components(separatedBy: ",").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                                )
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            default:
                                EmptyView()
                            }
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                        
                        // Navigation buttons
                        NavigationButtonsView(
                            currentStep: $currentStep,
                            totalSteps: steps.count,
                            canProceed: canProceedFromCurrentStep,
                            onCreateEvent: createEvent,
                            isCreating: $isCreating
                        )
                        .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .sheet(isPresented: $showingMapPicker) {
                MapPickerView(
                    selectedLocation: $selectedLocation,
                    locationName: $location,
                    mapRegion: $mapRegion
                )
            }
        }
    }
    
    private var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case 0:
            return !title.isEmpty && !details.isEmpty && startDate < endDate
        case 1:
            return true // Photo is optional
        case 2:
            return !location.isEmpty
        case 3:
            return true
        default:
            return false
        }
    }
    
    private func createEvent() {
        Task {
            isCreating = true
            defer { isCreating = false }
            
            let tagArray = tags.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            let maxAttendeesInt = Int(maxAttendees)
            
            await eventStore.createEnhancedEvent(
                title: title,
                details: details,
                location: location,
                startDate: startDate,
                endDate: endDate,
                hostId: hostId,
                category: category,
                maxAttendees: maxAttendeesInt,
                tags: tagArray,
                coverImageData: selectedPhotoData
            )
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            dismiss()
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? DesignSystem.Colors.primary : DesignSystem.Colors.background)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                    )
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentStep)
                
                if step < totalSteps - 1 {
                    Rectangle()
                        .fill(step < currentStep ? DesignSystem.Colors.primary : DesignSystem.Colors.background)
                        .frame(height: 2)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }
}

// MARK: - Basic Details Step
struct BasicDetailsStep: View {
    @Binding var title: String
    @Binding var details: String
    @Binding var category: EventCategory
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var maxAttendees: String
    @Binding var tags: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Tell us about your event")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                // Title
                MagicalTextField(
                    title: "Event Title",
                    text: $title,
                    placeholder: "What's your event called?"
                )
                
                // Category
                CategorySelector(selectedCategory: $category)
                
                // Description
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Description")
                        .font(DesignSystem.Typography.bodySemibold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    TextField("Tell everyone what to expect...", text: $details, axis: .vertical)
                        .textFieldStyle(MagicalTextFieldStyle())
                        .lineLimit(4...8)
                }
                
                // Date and time
                HStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Starts")
                            .font(DesignSystem.Typography.bodySemibold)
                            .foregroundColor(DesignSystem.Colors.text)
                        DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .modernCardStyle()
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Ends")
                            .font(DesignSystem.Typography.bodySemibold)
                            .foregroundColor(DesignSystem.Colors.text)
                        DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .modernCardStyle()
                    }
                }
                
                // Max attendees
                MagicalTextField(
                    title: "Max Attendees (Optional)",
                    text: $maxAttendees,
                    placeholder: "Leave empty for unlimited"
                )
                .keyboardType(.numberPad)
                
                // Tags
                MagicalTextField(
                    title: "Tags (Optional)",
                    text: $tags,
                    placeholder: "food, outdoor, family-friendly"
                )
            }
        }
    }
}

// MARK: - Photo Selection Step
struct PhotoSelectionStep: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedPhotoData: Data?
    @Binding var isUploadingPhoto: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Add a stunning photo")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            Text("Photos get 3x more engagement!")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            PhotoPickerCard(
                selectedPhotoItem: $selectedPhotoItem,
                selectedPhotoData: $selectedPhotoData,
                isUploadingPhoto: $isUploadingPhoto
            )
            
            if selectedPhotoData == nil {
                Text("Don't worry, you can always add photos later!")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let newItem = newItem {
                    isUploadingPhoto = true
                    selectedPhotoData = try? await newItem.loadTransferable(type: Data.self)
                    isUploadingPhoto = false
                }
            }
        }
    }
}

// MARK: - Location Selection Step
struct LocationSelectionStep: View {
    @Binding var location: String
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var showingMapPicker: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Where's the magic happening?")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                MagicalTextField(
                    title: "Location",
                    text: $location,
                    placeholder: "Enter address or venue name"
                )
                
                Button(action: { showingMapPicker = true }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Pick on Map")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                .modernCardStyle()
                
                if let selectedLocation = selectedLocation {
                    // Mini map preview
                    MapPreview(coordinate: selectedLocation, region: mapRegion)
                        .frame(height: 200)
                        .cornerRadius(DesignSystem.CornerRadius.lg)
                        .modernCardStyle()
                }
            }
        }
    }
}

// MARK: - Review Step
struct ReviewStep: View {
    let title: String
    let details: String
    let location: String
    let startDate: Date
    let endDate: Date
    let category: EventCategory
    let selectedPhotoData: Data?
    let tags: [String]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Looking amazing! 🎉")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            // Event preview card
            EventPreviewCard(
                title: title,
                details: details,
                location: location,
                startDate: startDate,
                endDate: endDate,
                category: category,
                selectedPhotoData: selectedPhotoData,
                tags: tags
            )
        }
    }
}

// MARK: - Supporting Views will be created in separate files for better organization

#Preview {
    EnhancedCreateEventView(hostId: UUID())
        .environmentObject(EventStore())
}