import SwiftUI

// MARK: - Onboarding Summary

struct OnboardingSummaryView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    let onComplete: () -> Void

    @State private var showFeatures = false
    @State private var showButton = false

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: LucentTheme.spacingXL) {
                    Spacer()
                        .frame(height: geo.size.height * 0.06)

                    // Checkmark icon
                    ZStack {
                        Circle()
                            .fill(LucentTheme.densityLow.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 46))
                            .foregroundColor(LucentTheme.densityLow)
                    }
                    .accessibilityHidden(true)
                    .scaleEffect(showFeatures ? 1.0 : 0.5)
                    .opacity(showFeatures ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showFeatures)

                    // Title
                    VStack(spacing: LucentTheme.spacingM) {
                        Text("We've personalized\nLucent for you.")
                            .font(LucentTheme.headingFont(size: 30))
                            .foregroundColor(LucentTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .accessibilityAddTraits(.isHeader)

                        Text("Based on your responses, here's what we've set up:")
                            .font(LucentTheme.bodyFont(size: 17))
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showFeatures ? 1.0 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.15), value: showFeatures)

                    // Enabled features list
                    VStack(spacing: LucentTheme.spacingS) {
                        ForEach(Array(vm.enabledFeatures.enumerated()), id: \.offset) { index, feature in
                            featureRow(icon: feature.icon, label: feature.label)
                                .opacity(showFeatures ? 1.0 : 0)
                                .offset(y: showFeatures ? 0 : 12)
                                .animation(
                                    .easeOut(duration: 0.4).delay(0.25 + Double(index) * 0.08),
                                    value: showFeatures
                                )
                        }
                    }
                    .frame(maxWidth: 480)

                    // Encouraging message
                    Text("You can adjust these anytime in settings.")
                        .font(LucentTheme.bodyFont(size: 16))
                        .foregroundColor(LucentTheme.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, LucentTheme.spacingS)
                        .opacity(showButton ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: showButton)

                    Spacer().frame(height: LucentTheme.spacingM)

                    // Start button
                    Button {
                        onComplete()
                    } label: {
                        HStack(spacing: LucentTheme.spacingS) {
                            Text("Start Learning")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(LucentPrimaryButtonStyle())
                    .frame(maxWidth: 340)
                    .opacity(showButton ? 1.0 : 0)
                    .scaleEffect(showButton ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showButton)
                    .accessibilityHint("Completes onboarding and opens the main app")

                    Spacer().frame(height: LucentTheme.spacingXXL)
                }
                .frame(maxWidth: LucentTheme.readingColumnMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingXL)
            }
        }
        .onAppear {
            // Stagger animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showFeatures = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showButton = true
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, label: String) -> some View {
        HStack(spacing: LucentTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(LucentTheme.accent)
                .frame(width: 32, height: 32)
                .background(LucentTheme.accentLight)
                .clipShape(Circle())

            Text(label)
                .font(LucentTheme.bodyFont(size: 17))
                .foregroundColor(LucentTheme.textPrimary)
                .lineSpacing(3)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(LucentTheme.densityLow)
        }
        .padding(.horizontal, LucentTheme.spacingM)
        .padding(.vertical, 14)
        .background(LucentTheme.surface)
        .cornerRadius(LucentTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        .accessibilityElement(children: .combine)
    }
}
