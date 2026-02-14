import SwiftUI

// MARK: - Lucent Design Tokens

enum LucentTheme {

    // MARK: Colors — Calming, high-contrast palette

    /// Soft cream background for light mode
    static let backgroundPrimary = Color("BackgroundPrimary", bundle: nil)
    static let backgroundSecondary = Color("BackgroundSecondary", bundle: nil)

    /// Adaptive background that works in both color schemes
    static var creamBackground: Color {
        Color(red: 0.98, green: 0.96, blue: 0.93)
    }

    static var softWhite: Color {
        Color(red: 0.99, green: 0.98, blue: 0.97)
    }

    /// Warm indigo accent
    static var accent: Color {
        Color(red: 0.33, green: 0.31, blue: 0.68)
    }

    /// Lighter accent for hover/highlights
    static var accentLight: Color {
        Color(red: 0.33, green: 0.31, blue: 0.68).opacity(0.12)
    }

    /// Primary text — dark charcoal, not pure black (easier on eyes)
    static var textPrimary: Color {
        Color(red: 0.17, green: 0.17, blue: 0.21)
    }

    /// Secondary text — softer gray
    static var textSecondary: Color {
        Color(red: 0.44, green: 0.44, blue: 0.50)
    }

    /// Sentence highlight — warm amber tint
    static var sentenceHighlight: Color {
        Color(red: 1.0, green: 0.92, blue: 0.70).opacity(0.55)
    }

    /// Word highlight during speech — brighter accent
    static var wordHighlight: Color {
        Color(red: 0.33, green: 0.31, blue: 0.68).opacity(0.25)
    }

    /// Cognitive density badge colors
    static var densityLow: Color {
        Color(red: 0.30, green: 0.69, blue: 0.53)
    }

    static var densityModerate: Color {
        Color(red: 0.90, green: 0.72, blue: 0.25)
    }

    static var densityHigh: Color {
        Color(red: 0.85, green: 0.35, blue: 0.35)
    }

    /// Surface color for cards and panels
    static var surface: Color {
        Color(red: 1.0, green: 1.0, blue: 1.0)
    }

    /// Subtle border/divider
    static var divider: Color {
        Color(red: 0.88, green: 0.87, blue: 0.86)
    }

    // MARK: Typography

    /// Dyslexia-friendly body font (rounded design)
    static func bodyFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func bodyFontMedium(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func headingFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static var title: Font {
        .system(size: 42, weight: .bold, design: .rounded)
    }

    static var subtitle: Font {
        .system(size: 20, weight: .regular, design: .rounded)
    }

    static var buttonFont: Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }

    static var caption: Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: Layout

    /// Max width for the centered reading column
    static let readingColumnMaxWidth: CGFloat = 680

    /// Standard corner radius
    static let cornerRadius: CGFloat = 14
    static let cornerRadiusSmall: CGFloat = 8

    /// Minimum tap target size (44pt Apple HIG)
    static let minTapTarget: CGFloat = 48
}

// MARK: - View Modifiers

struct LucentCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(LucentTheme.spacingL)
            .background(LucentTheme.surface)
            .cornerRadius(LucentTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct LucentPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LucentTheme.buttonFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                    .fill(LucentTheme.accent)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct LucentSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LucentTheme.buttonFont)
            .foregroundColor(LucentTheme.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                    .stroke(LucentTheme.accent, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func lucentCard() -> some View {
        modifier(LucentCardStyle())
    }
}
