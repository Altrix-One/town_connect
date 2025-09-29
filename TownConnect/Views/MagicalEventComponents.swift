import SwiftUI
import PhotosUI
import MapKit

// MARK: - Magical TextField
struct MagicalTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @State private var isFocused = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.text)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(MagicalTextFieldStyle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isFocused = true
                    }
                }
        }
    }
}

struct MagicalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .opacity(0)
                    .animation(.spring(response: 0.3), value: false)
            )
    }
}

// MARK: - Category Selector
struct CategorySelector: View {
    @Binding var selectedCategory: EventCategory
    
    private let categories: [EventCategory] = EventCategory.allCases
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Category")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: EventCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForCategory(category))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primary)
                Text(category.rawValue.capitalized)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [DesignSystem.Colors.secondaryBackground, DesignSystem.Colors.secondaryBackground],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                            .opacity(isSelected ? 0 : 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
    
    private func iconForCategory(_ category: EventCategory) -> String {
        switch category {
        case .community: return "building.2.fill"
        case .sports: return "sportscourt.fill"
        case .culture: return "theatermasks.fill"
        case .food: return "fork.knife"
        case .business: return "briefcase.fill"
        case .education: return "book.fill"
        case .family: return "house.fill"
        case .music: return "music.note"
        case .art: return "paintpalette.fill"
        case .social: return "person.3.fill"
        }
    }
}

// MARK: - Photo Picker Card
struct PhotoPickerCard: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedPhotoData: Data?
    @Binding var isUploadingPhoto: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Event Photo")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.text)
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                                .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
                        )
                    
                    if let selectedPhotoData,
                       let uiImage = UIImage(data: selectedPhotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(DesignSystem.CornerRadius.md)
                    } else {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            Text("Add Event Photo")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    if isUploadingPhoto {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 200)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let newItem = newItem {
                        isUploadingPhoto = true
                        defer { isUploadingPhoto = false }
                        
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Map Preview
struct MapPreview: View {
    let coordinate: CLLocationCoordinate2D
    let region: MKCoordinateRegion
    
    var body: some View {
        Map(coordinateRegion: .constant(region), interactionModes: [])
            .overlay(
                // Pin marker
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .shadow(radius: 2)
            )
    }
}

// MARK: - Small Map Preview
struct SmallMapPreview: View {
    let region: MKCoordinateRegion
    let locationName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Map(coordinateRegion: .constant(region), interactionModes: [])
                .frame(height: 120)
                .cornerRadius(DesignSystem.CornerRadius.md)
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                Text(locationName)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Map Picker View
struct MapPickerView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var locationName: String
    @Binding var mapRegion: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $mapRegion, interactionModes: .all, showsUserLocation: true)
                    .onTapGesture(coordinateSpace: .local) { location in
                        let coordinate = mapRegion.center
                        selectedLocation = coordinate
                        
                        // Reverse geocode to get location name
                        let geocoder = CLGeocoder()
                        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                            if let placemark = placemarks?.first {
                                DispatchQueue.main.async {
                                    locationName = placemark.name ?? "\(coordinate.latitude), \(coordinate.longitude)"
                                }
                            }
                        }
                    }
                    .overlay(
                        // Pin marker
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(DesignSystem.Colors.primary)
                            .shadow(radius: 3)
                    )
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    if !locationName.isEmpty {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text(locationName)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.text)
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .padding(.horizontal)
                    }
                    
                    Button("Use This Location") {
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .disabled(selectedLocation == nil)
                }
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Navigation Buttons
struct NavigationButtonsView: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onCreateEvent: () -> Void
    @Binding var isCreating: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Previous button
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep -= 1
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            // Next/Create button
            if currentStep < totalSteps - 1 {
                Button("Next") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canProceed)
            } else {
                Button("Create Event") {
                    onCreateEvent()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isCreating)
                .overlay(
                    Group {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Event Preview Card
struct EventPreviewCard: View {
    let title: String
    let details: String
    let location: String
    let startDate: Date
    let endDate: Date
    let category: EventCategory
    let selectedPhotoData: Data?
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with photo
            ZStack(alignment: .bottomLeading) {
                if let selectedPhotoData,
                   let uiImage = UIImage(data: selectedPhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.primaryLight.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                }
                
                // Category badge
                HStack {
                    Image(systemName: iconForCategory(category))
                    Text(category.rawValue.capitalized)
                        .font(DesignSystem.Typography.captionMedium)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(DesignSystem.CornerRadius.sm)
                .padding(DesignSystem.Spacing.md)
            }
            .cornerRadius(DesignSystem.CornerRadius.md)
            
            // Event details
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                
                Text(details)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(location)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(startDate, style: .date)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("•")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(startDate, style: .time)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                // Tags
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(DesignSystem.Typography.caption)
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs)
                                    .background(DesignSystem.Colors.primary.opacity(0.2))
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .cornerRadius(DesignSystem.CornerRadius.sm)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .designSystemShadow(DesignSystem.Shadows.medium)
    }
    
    private func iconForCategory(_ category: EventCategory) -> String {
        switch category {
        case .community: return "building.2.fill"
        case .sports: return "sportscourt.fill"
        case .culture: return "theatermasks.fill"
        case .food: return "fork.knife"
        case .business: return "briefcase.fill"
        case .education: return "book.fill"
        case .family: return "house.fill"
        case .music: return "music.note"
        case .art: return "paintpalette.fill"
        case .social: return "person.3.fill"
        }
    }
}

