import SwiftUI

// MARK: - Sentence Block View

struct SentenceBlockView: View {
    let sentence: ProcessedSentence
    let letterSpacing: Double
    let lineSpacing: Double
    let textSize: Double
    let isHighlighted: Bool
    let isFocused: Bool
    let focusDistance: Int
    let focusModeEnabled: Bool
    let onTap: () -> Void

    // Speech state
    let isSpeaking: Bool
    let currentWordIndex: Int?
    let speakingSentenceID: UUID?

    var body: some View {
        let isBeingSpoken = isSpeaking && speakingSentenceID == sentence.id

        Button(action: onTap) {
            buildTextView(isBeingSpoken: isBeingSpoken)
                .font(LucentTheme.bodyFont(size: textSize))
                .tracking(letterSpacing)
                .lineSpacing(lineSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, LucentTheme.spacingS)
                .padding(.horizontal, LucentTheme.spacingM)
                .background(backgroundView)
                .cornerRadius(LucentTheme.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
        .opacity(focusModeOpacity)
        .blur(radius: focusModeBlur)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
        .animation(.easeInOut(duration: 0.3), value: focusDistance)
        .animation(.easeInOut(duration: 0.15), value: currentWordIndex)
        .accessibilityLabel(sentence.text)
        .accessibilityHint("Tap to read this sentence aloud")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Text Builder

    @ViewBuilder
    private func buildTextView(isBeingSpoken: Bool) -> some View {
        if isBeingSpoken, let wordIdx = currentWordIndex {
            // Word-by-word highlight during speech
            buildHighlightedText(currentWordIndex: wordIdx)
        } else {
            Text(sentence.text)
                .foregroundColor(LucentTheme.textPrimary)
        }
    }

    private func buildHighlightedText(currentWordIndex: Int) -> some View {
        let words = sentence.words
        var result = Text("")

        for (index, word) in words.enumerated() {
            let separator = index == 0 ? "" : " "
            let wordText: Text

            if index == currentWordIndex {
                wordText = Text(separator + word)
                    .foregroundColor(LucentTheme.accent)
                    .fontWeight(.bold)
            } else if index < currentWordIndex {
                wordText = Text(separator + word)
                    .foregroundColor(LucentTheme.textPrimary.opacity(0.7))
            } else {
                wordText = Text(separator + word)
                    .foregroundColor(LucentTheme.textPrimary)
            }

            result = result + wordText
        }

        return result
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if isHighlighted {
            LucentTheme.sentenceHighlight
        } else if isFocused {
            LucentTheme.accentLight.opacity(0.5)
        } else {
            Color.clear
        }
    }

    // MARK: - Focus Mode

    private var focusModeOpacity: Double {
        guard focusModeEnabled else { return 1.0 }
        switch focusDistance {
        case 0: return 1.0
        case 1: return 0.75
        case 2: return 0.45
        default: return 0.2
        }
    }

    private var focusModeBlur: CGFloat {
        guard focusModeEnabled else { return 0 }
        switch focusDistance {
        case 0, 1: return 0
        case 2: return 1
        default: return 2.5
        }
    }
}
