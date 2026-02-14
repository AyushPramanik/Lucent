import SwiftUI

// MARK: - Clarity View (Main Reading Screen)

struct ClarityView: View {
    @EnvironmentObject var viewModel: ReadingViewModel
    @State private var showSettings = false
    @State private var scrollToSentenceID: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar
            topBar

            Divider()
                .foregroundColor(LucentTheme.divider)

            // MARK: - Reading Content
            if viewModel.paragraphs.isEmpty {
                emptyState
            } else {
                readingContent
            }
        }
        .background(LucentTheme.creamBackground.ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            ControlPanelView()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: viewModel.focusedSentenceID) { newID in
            if let id = newID {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollToSentenceID = id
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: LucentTheme.spacingM) {
            // Cognitive Load Badge
            CognitiveLoadBadge(density: viewModel.density)

            Spacer()

            // Focus mode navigation (when focus mode is on)
            if viewModel.focusModeEnabled {
                HStack(spacing: LucentTheme.spacingS) {
                    Button {
                        viewModel.focusPreviousSentence()
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .foregroundColor(LucentTheme.accent)
                            .background(LucentTheme.accentLight)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Previous sentence")

                    Button {
                        viewModel.focusNextSentence()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .foregroundColor(LucentTheme.accent)
                            .background(LucentTheme.accentLight)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Next sentence")
                }
            }

            // Stop speech button
            if viewModel.speechManager.isSpeaking {
                Button {
                    viewModel.stopSpeaking()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(LucentTheme.densityHigh)
                }
                .accessibilityLabel("Stop reading aloud")
                .transition(.scale.combined(with: .opacity))
            }

            // Settings button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 44, height: 44)
                    .foregroundColor(LucentTheme.accent)
                    .background(LucentTheme.accentLight)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Reading settings")
            .accessibilityHint("Opens typography, focus mode, and speech controls")
        }
        .padding(.horizontal, LucentTheme.spacingL)
        .padding(.vertical, LucentTheme.spacingM)
        .background(LucentTheme.surface.opacity(0.9))
    }

    // MARK: - Reading Content

    private var readingContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: LucentTheme.spacingXL) {
                    ForEach(viewModel.paragraphs) { paragraph in
                        paragraphBlock(paragraph)
                    }
                }
                .frame(maxWidth: LucentTheme.readingColumnMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingL)
                .padding(.vertical, LucentTheme.spacingXL)
            }
            .onChange(of: scrollToSentenceID) { newID in
                if let id = newID {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Paragraph Block

    @ViewBuilder
    private func paragraphBlock(_ paragraph: ProcessedParagraph) -> some View {
        VStack(alignment: .leading, spacing: LucentTheme.spacingS) {
            ForEach(paragraph.sentences) { sentence in
                SentenceBlockView(
                    sentence: sentence,
                    letterSpacing: viewModel.letterSpacing,
                    lineSpacing: viewModel.lineSpacing,
                    textSize: viewModel.textSize,
                    isHighlighted: viewModel.highlightSentenceEnabled &&
                        viewModel.focusedSentenceID == sentence.id,
                    isFocused: viewModel.focusedSentenceID == sentence.id,
                    focusDistance: viewModel.distanceFromFocus(sentence.id),
                    focusModeEnabled: viewModel.focusModeEnabled,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.focusedSentenceID = sentence.id
                        }
                        viewModel.speakSentence(sentence)
                    },
                    isSpeaking: viewModel.speechManager.isSpeaking,
                    currentWordIndex: viewModel.speechManager.currentWordIndex,
                    speakingSentenceID: viewModel.speechManager.isSpeaking ?
                        viewModel.focusedSentenceID : nil
                )
                .id(sentence.id)
            }
        }
        .padding(LucentTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                .fill(LucentTheme.surface)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LucentTheme.spacingM) {
            Spacer()
            Image(systemName: "text.alignleft")
                .font(.system(size: 48))
                .foregroundColor(LucentTheme.accent.opacity(0.4))
            Text("No text to display")
                .font(LucentTheme.bodyFont(size: 18))
                .foregroundColor(LucentTheme.textSecondary)
            Text("Go back and paste or import some text.")
                .font(LucentTheme.bodyFont(size: 15))
                .foregroundColor(LucentTheme.textSecondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
