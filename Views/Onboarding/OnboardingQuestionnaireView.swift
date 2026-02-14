import SwiftUI

// MARK: - Onboarding Questionnaire

struct OnboardingQuestionnaireView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @State private var questionStep: Int = 0

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: LucentTheme.spacingXL) {
                    Spacer()
                        .frame(height: geo.size.height * 0.04)

                    // Page header
                    VStack(spacing: LucentTheme.spacingS) {
                        Text("Tell us how you learn best")
                            .font(LucentTheme.headingFont(size: 30))
                            .foregroundColor(LucentTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("Select all that apply. This helps us personalize your reading experience.")
                            .font(LucentTheme.bodyFont(size: 17))
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    // Question step indicator
                    questionStepIndicator

                    // Questions
                    switch questionStep {
                    case 0:
                        questionSection(
                            number: "1",
                            title: "What do you find most challenging when reading slides?",
                            options: vm.challengeOptions,
                            selections: vm.challengeSelections,
                            isMultiSelect: true,
                            onToggle: { vm.toggleChallenge($0) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    case 1:
                        questionSection(
                            number: "2",
                            title: "What helps you understand better?",
                            options: vm.helpsOptions,
                            selections: vm.helpsSelections,
                            isMultiSelect: true,
                            onToggle: { vm.toggleHelps($0) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    default:
                        questionSection(
                            number: "3",
                            title: "How do you prefer to study?",
                            options: vm.studyOptions,
                            selections: vm.studyPreference.map { Set([$0]) } ?? [],
                            isMultiSelect: false,
                            onToggle: { vm.selectStudyPreference($0) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }

                    Spacer().frame(height: LucentTheme.spacingM)

                    // Navigation
                    navigationButtons

                    Spacer().frame(height: LucentTheme.spacingXL)
                }
                .frame(maxWidth: LucentTheme.readingColumnMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingXL)
            }
        }
    }

    // MARK: - Question Step Indicator

    private var questionStepIndicator: some View {
        HStack(spacing: LucentTheme.spacingS) {
            ForEach(0..<3, id: \.self) { step in
                HStack(spacing: 4) {
                    Circle()
                        .fill(step <= questionStep ? LucentTheme.accent : LucentTheme.divider)
                        .frame(width: 8, height: 8)

                    if step == questionStep {
                        Text("Question \(step + 1) of 3")
                            .font(LucentTheme.caption)
                            .foregroundColor(LucentTheme.accent)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: questionStep)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Question \(questionStep + 1) of 3")
    }

    // MARK: - Question Section

    @ViewBuilder
    private func questionSection(
        number: String,
        title: String,
        options: [OnboardingOption],
        selections: Set<String>,
        isMultiSelect: Bool,
        onToggle: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: LucentTheme.spacingL) {
            Text(title)
                .font(LucentTheme.bodyFontMedium(size: 20))
                .foregroundColor(LucentTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            if isMultiSelect {
                Text("Select all that apply")
                    .font(LucentTheme.caption)
                    .foregroundColor(LucentTheme.textSecondary)
            } else {
                Text("Choose one")
                    .font(LucentTheme.caption)
                    .foregroundColor(LucentTheme.textSecondary)
            }

            // Option cards — 2-column grid for iPad
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: LucentTheme.spacingM),
                GridItem(.flexible(), spacing: LucentTheme.spacingM)
            ], spacing: LucentTheme.spacingM) {
                ForEach(options) { option in
                    SelectableCard(
                        option: option,
                        isSelected: selections.contains(option.id),
                        onTap: { onToggle(option.id) }
                    )
                }
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: LucentTheme.spacingM) {
            // Back button
            Button {
                if questionStep > 0 {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        questionStep -= 1
                    }
                } else {
                    vm.previousPage()
                }
            } label: {
                Text("Back")
            }
            .buttonStyle(LucentSecondaryButtonStyle())

            // Next / Personalize button
            if questionStep < 2 {
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        questionStep += 1
                    }
                } label: {
                    Text("Next")
                }
                .buttonStyle(LucentPrimaryButtonStyle())
                .disabled(currentStepEmpty)
                .opacity(currentStepEmpty ? 0.5 : 1.0)
            } else {
                Button {
                    vm.applyPersonalization()
                    vm.nextPage()
                } label: {
                    HStack(spacing: LucentTheme.spacingS) {
                        Image(systemName: "sparkles")
                        Text("Personalize My Reading")
                    }
                }
                .buttonStyle(LucentPrimaryButtonStyle())
                .disabled(!vm.canAdvanceFromQuestionnaire)
                .opacity(vm.canAdvanceFromQuestionnaire ? 1.0 : 0.5)
            }
        }
        .frame(maxWidth: 440)
    }

    private var currentStepEmpty: Bool {
        switch questionStep {
        case 0: return vm.challengeSelections.isEmpty
        case 1: return vm.helpsSelections.isEmpty
        default: return vm.studyPreference == nil
        }
    }
}

// MARK: - Selectable Card

struct SelectableCard: View {
    let option: OnboardingOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }) {
            HStack(spacing: LucentTheme.spacingM) {
                Image(systemName: option.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? LucentTheme.accent : LucentTheme.textSecondary)
                    .frame(width: 28)

                Text(option.label)
                    .font(LucentTheme.bodyFont(size: 16))
                    .foregroundColor(LucentTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(LucentTheme.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(LucentTheme.spacingM)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                    .fill(isSelected ? LucentTheme.accentLight : LucentTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                    .stroke(
                        isSelected ? LucentTheme.accent : LucentTheme.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.06 : 0.02), radius: 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.0 : 0.98)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(isSelected ? "Selected. Tap to deselect." : "Tap to select.")
    }
}
