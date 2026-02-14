import SwiftUI

// MARK: - Control Panel

struct ControlPanelView: View {
    @EnvironmentObject var viewModel: ReadingViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LucentTheme.spacingXL) {

                    // MARK: - Typography Section
                    controlSection(title: "Typography", icon: "textformat.size") {
                        VStack(spacing: LucentTheme.spacingL) {
                            // Text Size
                            LabeledSlider(
                                label: "Text Size",
                                value: $viewModel.textSize,
                                range: 18...40,
                                step: 1,
                                displayValue: "\(Int(viewModel.textSize))pt",
                                icon: "textformat.size"
                            )

                            // Letter Spacing
                            LabeledSlider(
                                label: "Letter Spacing",
                                value: $viewModel.letterSpacing,
                                range: 0...10,
                                step: 0.5,
                                displayValue: String(format: "%.1f", viewModel.letterSpacing),
                                icon: "arrow.left.and.right"
                            )

                            // Line Spacing
                            LabeledSlider(
                                label: "Line Spacing",
                                value: $viewModel.lineSpacing,
                                range: 4...20,
                                step: 1,
                                displayValue: "\(Int(viewModel.lineSpacing))pt",
                                icon: "arrow.up.and.down"
                            )
                        }
                    }

                    // MARK: - Reading Modes Section
                    controlSection(title: "Reading Modes", icon: "eye") {
                        VStack(spacing: LucentTheme.spacingL) {
                            SettingsToggle(
                                label: "Focus Mode",
                                description: "Show only 2–3 lines at a time",
                                icon: "eye.circle",
                                isOn: $viewModel.focusModeEnabled
                            )

                            SettingsToggle(
                                label: "Highlight Sentence",
                                description: "Highlight the active sentence",
                                icon: "highlighter",
                                isOn: $viewModel.highlightSentenceEnabled
                            )
                        }
                    }

                    // MARK: - Speech Section
                    controlSection(title: "Read Aloud", icon: "speaker.wave.2") {
                        LabeledSlider(
                            label: "Speech Rate",
                            value: $viewModel.speechRate,
                            range: 0.2...0.65,
                            step: 0.05,
                            displayValue: speechRateLabel,
                            icon: "gauge.medium"
                        )
                    }
                }
                .padding(LucentTheme.spacingL)
            }
            .background(LucentTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var speechRateLabel: String {
        if viewModel.speechRate < 0.35 {
            return "Slow"
        } else if viewModel.speechRate < 0.50 {
            return "Normal"
        } else {
            return "Fast"
        }
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func controlSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LucentTheme.spacingM) {
            HStack(spacing: LucentTheme.spacingS) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(LucentTheme.accent)
                Text(title)
                    .font(LucentTheme.bodyFontMedium(size: 17))
                    .foregroundColor(LucentTheme.textPrimary)
            }
            .accessibilityAddTraits(.isHeader)

            content()
        }
        .padding(LucentTheme.spacingL)
        .background(LucentTheme.surface)
        .cornerRadius(LucentTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Labeled Slider

private struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let displayValue: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: LucentTheme.spacingS) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(LucentTheme.textSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(LucentTheme.bodyFont(size: 15))
                    .foregroundColor(LucentTheme.textPrimary)
                Spacer()
                Text(displayValue)
                    .font(LucentTheme.bodyFontMedium(size: 15))
                    .foregroundColor(LucentTheme.accent)
                    .frame(minWidth: 50, alignment: .trailing)
            }

            Slider(value: $value, in: range, step: step)
                .tint(LucentTheme.accent)
                .accessibilityLabel(label)
                .accessibilityValue(displayValue)
        }
    }
}

// MARK: - Settings Toggle

private struct SettingsToggle: View {
    let label: String
    let description: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: LucentTheme.spacingS) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(LucentTheme.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(LucentTheme.bodyFont(size: 16))
                        .foregroundColor(LucentTheme.textPrimary)
                    Text(description)
                        .font(LucentTheme.caption)
                        .foregroundColor(LucentTheme.textSecondary)
                }
            }
        }
        .tint(LucentTheme.accent)
        .accessibilityLabel("\(label): \(description)")
    }
}
