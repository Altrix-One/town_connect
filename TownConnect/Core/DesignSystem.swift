import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors - Vibrant and Modern
        static let primary = Color(red: 0.3, green: 0.6, blue: 1.0) // Bright blue
        static let primaryLight = Color(red: 0.5, green: 0.8, blue: 1.0)
        static let primaryDark = Color(red: 0.1, green: 0.3, blue: 0.8)
        
        // Vibrant Accent Colors
        static let accent = Color(red: 1.0, green: 0.45, blue: 0.6) // Hot pink
        static let accentLight = Color(red: 1.0, green: 0.7, blue: 0.8)
        static let accentDark = Color(red: 0.8, green: 0.2, blue: 0.4)
        
        // Social Colors
        static let success = Color(red: 0.0, green: 0.8, blue: 0.4) // Bright green
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0) // Vibrant yellow
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3) // Bright red
        static let love = Color(red: 1.0, green: 0.2, blue: 0.4) // Love red
        static let info = Color(red: 0.2, green: 0.7, blue: 1.0) // Info blue
        
        // Category Colors
        static let community = Color(red: 0.5, green: 0.3, blue: 1.0) // Purple
        static let sports = Color(red: 0.0, green: 0.8, blue: 0.2) // Sports green
        static let culture = Color(red: 1.0, green: 0.6, blue: 0.0) // Culture orange
        static let food = Color(red: 1.0, green: 0.4, blue: 0.4) // Food red
        static let business = Color(red: 0.2, green: 0.5, blue: 0.8) // Business blue
        static let music = Color(red: 0.8, green: 0.2, blue: 0.8) // Music magenta
        
        // Background Colors - Dynamic
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        // Text Colors
        static let text = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)
        static let textInverse = Color.white
        
        // Border Colors
        static let border = Color(UIColor.separator)
        static let borderSecondary = Color(UIColor.opaqueSeparator)
        
        // Surface Colors with Glassmorphism
        static let surface = Color(UIColor.systemBackground)
        static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
        static let surfaceTertiary = Color(UIColor.tertiarySystemBackground)
        
        // Glass Effect Colors - Enhanced
        static let glassBackground = Color.white.opacity(0.15)
        static let glassBorder = Color.white.opacity(0.3)
        static let glassBackgroundDark = Color.black.opacity(0.15)
        static let glassBorderDark = Color.white.opacity(0.1)
        
        // Overlay Colors
        static let overlay = Color.black.opacity(0.3)
        static let overlayLight = Color.black.opacity(0.1)
        static let overlayHeavy = Color.black.opacity(0.6)
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
    
    // MARK: - Gradients
    struct Gradients {
        // Primary gradients
        static let primaryGradient = LinearGradient(
            colors: [Colors.primary, Colors.primaryLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accentGradient = LinearGradient(
            colors: [Colors.accent, Colors.accentLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Vibrant gradients for categories
        static let communityGradient = LinearGradient(
            colors: [Colors.community, Colors.primary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let sportsGradient = LinearGradient(
            colors: [Colors.sports, Colors.success],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cultureGradient = LinearGradient(
            colors: [Colors.culture, Colors.warning],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let foodGradient = LinearGradient(
            colors: [Colors.food, Colors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Background gradients
        static let backgroundGradient = LinearGradient(
            colors: [Colors.background, Colors.secondaryBackground],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let glassGradient = LinearGradient(
            colors: [Colors.glassBackground, Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Social gradients
        static let loveGradient = LinearGradient(
            colors: [Colors.love, Colors.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let successGradient = LinearGradient(
            colors: [Colors.success, Color(red: 0.2, green: 1.0, blue: 0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Radial gradients for special effects
        static let spotlightGradient = RadialGradient(
            colors: [Color.white.opacity(0.3), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    }
    
    // MARK: - Animation
    struct Animation {
        // Basic animations
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.8)
        
        // Spring animations
        static let bounce = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let snappy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.9)
        static let elastic = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.6)
        
        // Special animations
        static let heartbeat = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.3)
        static let wiggle = SwiftUI.Animation.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)
        static let pulse = SwiftUI.Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
        
        // Entrance animations
        static let slideIn = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
        static let fadeIn = SwiftUI.Animation.easeOut(duration: 0.4)
        static let scaleIn = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
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
    
    // Enhanced glass morphism effect
    func glassMaterial(cornerRadius: CGFloat = DesignSystem.CornerRadius.md) -> some View {
        self
            .background(DesignSystem.Colors.glassBackground)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
            )
            .designSystemShadow(DesignSystem.Shadows.light)
    }
    
    // Enhanced glass with gradient
    func vibrantGlassMaterial(cornerRadius: CGFloat = DesignSystem.CornerRadius.lg) -> some View {
        self
            .background(DesignSystem.Gradients.glassGradient)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.8)
            )
            .designSystemShadow(DesignSystem.Shadows.medium)
    }
    
    // Modern card styles with gradients
    func modernCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .designSystemShadow(DesignSystem.Shadows.light)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.border.opacity(0.3), lineWidth: 0.5)
            )
    }
    
    func elevatedCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .designSystemShadow(DesignSystem.Shadows.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.border.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    // Social interaction styles
    func socialCardStyle() -> some View {
        self
            .modernCardStyle()
            .overlay(
                DesignSystem.Gradients.spotlightGradient
                    .allowsHitTesting(false)
                    .opacity(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            )
    }
    
    // Gradient background
    func gradientBackground(_ gradient: LinearGradient) -> some View {
        self
            .background(gradient)
    }
    
    // Interactive scaling effect
    func interactiveScale(scale: CGFloat = 0.98) -> some View {
        self.scaleEffect(scale)
    }
    
    // Shimmer effect for loading
    func shimmerEffect() -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .animation(DesignSystem.Animation.pulse, value: true)
            )
            .clipped()
    }
    
    // Bounce animation on tap
    func bounceOnTap() -> some View {
        self.onTapGesture {
            withAnimation(DesignSystem.Animation.bounce) {
                // Trigger bounce effect in parent view
            }
        }
    }
}

// MARK: - Modern Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Gradients.primaryGradient)
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.medium)
            .disabled(isLoading)
            .animation(DesignSystem.Animation.bounce, value: configuration.isPressed)
    }
}

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Gradients.accentGradient)
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.medium)
            .animation(DesignSystem.Animation.bounce, value: configuration.isPressed)
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
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignSystem.Animation.snappy, value: configuration.isPressed)
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonMedium)
            .foregroundColor(DesignSystem.Colors.text)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .designSystemShadow(DesignSystem.Shadows.light)
            .animation(DesignSystem.Animation.smooth, value: configuration.isPressed)
    }
}

struct CompactButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    
    init(gradient: LinearGradient = DesignSystem.Gradients.primaryGradient) {
        self.gradient = gradient
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonSmall)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                    .fill(gradient)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.light)
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
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.error, Color(red: 1.0, green: 0.5, blue: 0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
                    .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            )
            .designSystemShadow(DesignSystem.Shadows.medium)
            .animation(DesignSystem.Animation.bounce, value: configuration.isPressed)
    }
}

// Social interaction button styles
struct LikeButtonStyle: ButtonStyle {
    let isLiked: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isLiked ? .white : DesignSystem.Colors.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isLiked ? 
                        DesignSystem.Gradients.loveGradient :
                        LinearGradient(colors: [DesignSystem.Colors.surface], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                isLiked ? Color.clear : DesignSystem.Colors.border,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(DesignSystem.Animation.heartbeat, value: configuration.isPressed)
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