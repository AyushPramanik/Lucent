import SwiftUI

// MARK: - Cognitive Load Badge

struct CognitiveLoadBadge: View {
    let density: CognitiveDensity

    var body: some View {
        HStack(spacing: LucentTheme.spacingXS) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)

            Text(density.description)
                .font(LucentTheme.caption)
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(badgeColor.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(badgeColor.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(density.accessibilityLabel)
    }

    private var badgeColor: Color {
        switch density {
        case .low:
            return LucentTheme.densityLow
        case .moderate:
            return LucentTheme.densityModerate
        case .high:
            return LucentTheme.densityHigh
        }
    }
}
