import SwiftUI

// MARK: - Onboarding Container

struct OnboardingContainerView: View {
    @StateObject private var onboardingVM = OnboardingViewModel()
    @EnvironmentObject var readingVM: ReadingViewModel

    var body: some View {
        ZStack {
            LucentTheme.creamBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator
                pageIndicator
                    .padding(.top, LucentTheme.spacingM)

                // Page content
                TabView(selection: $onboardingVM.currentPage) {
                    welcomePage
                        .tag(OnboardingPage.welcome)

                    understandingPage
                        .tag(OnboardingPage.understanding)

                    OnboardingQuestionnaireView()
                        .environmentObject(onboardingVM)
                        .tag(OnboardingPage.questionnaire)

                    OnboardingSummaryView {
                        onboardingVM.completeOnboarding()
                        readingVM.loadPreferences()
                    }
                    .environmentObject(onboardingVM)
                    .tag(OnboardingPage.summary)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: onboardingVM.currentPage)
            }
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: LucentTheme.spacingS) {
            ForEach(OnboardingPage.allCases, id: \.rawValue) { page in
                Capsule()
                    .fill(page == onboardingVM.currentPage
                          ? LucentTheme.accent
                          : LucentTheme.accent.opacity(0.2))
                    .frame(
                        width: page == onboardingVM.currentPage ? 28 : 10,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.3), value: onboardingVM.currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(onboardingVM.currentPage.rawValue + 1) of \(OnboardingPage.allCases.count)")
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: LucentTheme.spacingXL) {
                    Spacer()
                        .frame(height: geo.size.height * 0.12)

                    // Icon
                    ZStack {
                        Circle()
                            .fill(LucentTheme.accentLight)
                            .frame(width: 110, height: 110)
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 48))
                            .foregroundColor(LucentTheme.accent)
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: LucentTheme.spacingM) {
                        Text("Welcome to Lucent")
                            .font(LucentTheme.title)
                            .foregroundColor(LucentTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("A reading companion designed\nwith you in mind.")
                            .font(LucentTheme.bodyFont(size: 20))
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                    }

                    VStack(spacing: LucentTheme.spacingS) {
                        Text("We'll ask you a few quick questions\nto personalize your experience.")
                            .font(LucentTheme.bodyFont(size: 17))
                            .foregroundColor(LucentTheme.textSecondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.top, LucentTheme.spacingM)

                    Spacer().frame(height: LucentTheme.spacingXL)

                    Button {
                        onboardingVM.nextPage()
                    } label: {
                        Text("Get Started")
                    }
                    .buttonStyle(LucentPrimaryButtonStyle())
                    .frame(maxWidth: 340)
                    .accessibilityHint("Begins the onboarding questionnaire")
                }
                .frame(maxWidth: LucentTheme.readingColumnMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingXL)
            }
        }
    }

    // MARK: - Page 2: Understanding Dyslexia

    private var understandingPage: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: LucentTheme.spacingXL) {
                    Spacer()
                        .frame(height: geo.size.height * 0.08)

                    // Icon
                    ZStack {
                        Circle()
                            .fill(LucentTheme.densityLow.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40))
                            .foregroundColor(LucentTheme.densityLow)
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: LucentTheme.spacingM) {
                        Text("Understanding Dyslexia")
                            .font(LucentTheme.headingFont(size: 32))
                            .foregroundColor(LucentTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("Dyslexia is not about intelligence.\nIt's about how your brain processes text.")
                            .font(LucentTheme.bodyFont(size: 19))
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                    }

                    // Empowering facts
                    VStack(spacing: LucentTheme.spacingM) {
                        insightCard(
                            icon: "sparkles",
                            text: "Dyslexic thinkers often excel at big-picture thinking, creativity, and problem-solving."
                        )
                        insightCard(
                            icon: "arrow.triangle.branch",
                            text: "Your brain takes a different path to read — not a wrong one."
                        )
                        insightCard(
                            icon: "gearshape.2",
                            text: "Lucent adapts to the way you read, so you can focus on what matters."
                        )
                    }
                    .frame(maxWidth: 520)

                    Spacer().frame(height: LucentTheme.spacingL)

                    HStack(spacing: LucentTheme.spacingM) {
                        Button {
                            onboardingVM.previousPage()
                        } label: {
                            Text("Back")
                        }
                        .buttonStyle(LucentSecondaryButtonStyle())

                        Button {
                            onboardingVM.nextPage()
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(LucentPrimaryButtonStyle())
                    }
                    .frame(maxWidth: 400)

                    Spacer().frame(height: LucentTheme.spacingXL)
                }
                .frame(maxWidth: LucentTheme.readingColumnMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingXL)
            }
        }
    }

    // MARK: - Insight Card

    private func insightCard(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: LucentTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(LucentTheme.accent)
                .frame(width: 36, height: 36)
                .background(LucentTheme.accentLight)
                .clipShape(Circle())

            Text(text)
                .font(LucentTheme.bodyFont(size: 17))
                .foregroundColor(LucentTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(LucentTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LucentTheme.surface)
        .cornerRadius(LucentTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        .accessibilityElement(children: .combine)
    }
}
