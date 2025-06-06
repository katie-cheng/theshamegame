import SwiftUI

struct Theme {
    
    // MARK: - Colors (Dark Mode Only)
    
    struct Colors {
        // Primary Blues/Purples
        static let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95) // #4059F2
        static let primaryPurple = Color(red: 0.45, green: 0.25, blue: 0.85) // #7340D9
        static let lightBlue = Color(red: 0.35, green: 0.45, blue: 0.98) // #5973FA
        static let lightPurple = Color(red: 0.55, green: 0.35, blue: 0.90) // #8C59E6
        
        // Background Colors
        static let background = Color(red: 0.08, green: 0.08, blue: 0.12) // #14141F
        static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.18) // #1F1F2E
        static let inputBackground = Color(red: 0.15, green: 0.15, blue: 0.22) // #262638
        
        // Text Colors
        static let primaryText = Color.white
        static let secondaryText = Color(red: 0.7, green: 0.7, blue: 0.8) // #B3B3CC
        static let accentText = Color(red: 0.85, green: 0.85, blue: 0.95) // #D9D9F2
        
        // Status Colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933
        static let danger = Color(red: 0.9, green: 0.3, blue: 0.3) // #E64D4D
        static let shame = Color(red: 0.85, green: 0.2, blue: 0.2) // #D93333
        
        // Gradient Colors
        static let primaryGradient = LinearGradient(
            colors: [primaryBlue, primaryPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [cardBackground, inputBackground],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let successGradient = LinearGradient(
            colors: [success, Color(red: 0.1, green: 0.7, blue: 0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let shameGradient = LinearGradient(
            colors: [shame, Color(red: 0.9, green: 0.4, blue: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Shadows
    
    struct Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                isEnabled ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryText], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(Theme.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.callout)
            .foregroundColor(Theme.Colors.primaryBlue)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(Theme.Colors.primaryBlue, lineWidth: 1)
            )
            .cornerRadius(Theme.CornerRadius.small)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ShameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.shameGradient)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Colors.shame.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct WakeUpButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.title)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.vertical, Theme.Spacing.lg)
            .background(Theme.Colors.successGradient)
            .cornerRadius(Theme.CornerRadius.extraLarge)
            .shadow(color: Theme.Colors.success.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Custom Card Style

struct CardModifier: ViewModifier {
    let padding: CGFloat
    
    init(padding: CGFloat = Theme.Spacing.md) {
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.Colors.cardGradient)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Shadow.medium.color, radius: Theme.Shadow.medium.radius, x: Theme.Shadow.medium.x, y: Theme.Shadow.medium.y)
    }
}

// MARK: - Custom TextField Style

struct ThemedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Theme.Typography.body)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.inputBackground)
            .cornerRadius(Theme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(Theme.Colors.primaryBlue.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self.modifier(CardModifier(padding: padding))
    }
    
    func primaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    func shameButton() -> some View {
        self.buttonStyle(ShameButtonStyle())
    }
    
    func wakeUpButton() -> some View {
        self.buttonStyle(WakeUpButtonStyle())
    }
    
    func themedTextField() -> some View {
        self.textFieldStyle(ThemedTextFieldStyle())
    }
} 