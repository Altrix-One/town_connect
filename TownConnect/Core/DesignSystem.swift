import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primary = Color("PrimaryBlue") // Keep existing brand color
        static let primaryLight = Color(red: 0.4, green: 0.7, blue: 1.0)
        static let primaryDark = Color(red: 0.1, green: 0.3, blue: 0.7)
        
        // Secondary Colors
        static let accent = Color(red: 0.95, green: 0.4, blue: 0.27) // Coral
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let warning = Color(red: 1.0, green: 0.75, blue: 0.0)
        static let error = Color(red: 0.96, green: 0.26, blue: 0.21)
        
        // Neutral Colors
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        static let text = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)
        
        static let border = Color(UIColor.separator)
        static let borderSecondary = Color(UIColor.opaqueSeparator)
        
        // Surface Colors
        static let surface = Color(UIColor.systemBackground)
        static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
        static let surfaceTertiary = Color(UIColor.tertiarySystemBackground)
        
        // Glass Effect Colors
        static let glassBackground = Color.white.opacity(0.1)
        static let glassBorder = Color.white.opacity(0.2)
    }
    
    // MARK: - Typography
    struct Typography {
        // Headings
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // Body Text
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let bodySemibold = Font.body.weight(.semibold)
        
        // Supporting Text
        static let caption = Font.caption
        static let captionMedium = Font.caption.weight(.medium)
        static let footnote = Font.footnote
        static let footnoteMedium = Font.footnote.weight(.medium)
        
        // Button Text
        static let buttonLarge = Font.headline.weight(.semibold)
        static let buttonMedium = Font.subheadline.weight(.semibold)
        static let buttonSmall = Font.caption.weight(.semibold)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let pill: CGFloat = 999
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        static let heavy = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 4)
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let bounce = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Design System
extension View {
    func designSystemShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func glassMaterial() -> some View {
        self
            .background(DesignSystem.Colors.glassBackground)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
            )
    }
    
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .designSystemShadow(DesignSystem.Shadows.light)
    }
    
    func elevatedCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .designSystemShadow(DesignSystem.Shadows.medium)
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.primary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.light)
            .disabled(isLoading)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(DesignSystem.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.primary, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.surface)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.error)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.light)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - User Type Badge Component
struct UserTypeBadge: View {
    let userType: UserType
    
    private var badgeColor: Color {
        switch userType {
        case .resident:
            return DesignSystem.Colors.primary
        case .businessOwner:
            return DesignSystem.Colors.accent
        case .eventOrganizer:
            return DesignSystem.Colors.success
        case .communityLeader:
            return DesignSystem.Colors.warning
        case .admin:
            return DesignSystem.Colors.error
        }
    }
    
    private var badgeIcon: String {
        switch userType {
        case .resident:
            return "house.fill"
        case .businessOwner:
            return "briefcase.fill"
        case .eventOrganizer:
            return "calendar.badge.plus"
        case .communityLeader:
            return "crown.fill"
        case .admin:
            return "shield.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: badgeIcon)
                .font(.caption2)
            Text(userType.displayName)
                .font(DesignSystem.Typography.captionMedium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(badgeColor)
        )
    }
}