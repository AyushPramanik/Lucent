import SwiftUI

// MARK: - Onboarding Data Models

struct OnboardingOption: Identifiable, Equatable {
    let id: String
    let label: String
    let icon: String
}

enum OnboardingPage: Int, CaseIterable {
    case welcome = 0
    case understanding = 1
    case questionnaire = 2
    case summary = 3
}

// MARK: - Onboarding ViewModel

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Navigation

    @Published var currentPage: OnboardingPage = .welcome

    // MARK: - Persistence

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("prefTextSize") var prefTextSize: Double = 22.0
    @AppStorage("prefLineSpacing") var prefLineSpacing: Double = 8.0
    @AppStorage("prefLetterSpacing") var prefLetterSpacing: Double = 1.5
    @AppStorage("prefFocusMode") var prefFocusMode: Bool = false
    @AppStorage("prefHighlightSentence") var prefHighlightSentence: Bool = false
    @AppStorage("prefSpeechRate") var prefSpeechRate: Double = 0.45
    @AppStorage("prefReadAloudHighlight") var prefReadAloudHighlight: Bool = false
    @AppStorage("prefSentenceChunking") var prefSentenceChunking: Bool = true

    // MARK: - Selections

    @Published var challengeSelections: Set<String> = []
    @Published var helpsSelections: Set<String> = []
    @Published var studyPreference: String? = nil

    // MARK: - Questions Data

    let challengeOptions: [OnboardingOption] = [
        OnboardingOption(id: "long_sentences", label: "Long sentences feel overwhelming", icon: "text.alignleft"),
        OnboardingOption(id: "dense_paragraphs", label: "Dense paragraphs are hard to follow", icon: "doc.text.fill"),
        OnboardingOption(id: "lose_place", label: "I lose my place while reading", icon: "eye.slash"),
        OnboardingOption(id: "read_slowly", label: "I read slowly", icon: "tortoise"),
        OnboardingOption(id: "pronunciation", label: "I struggle with pronunciation", icon: "mouth"),
        OnboardingOption(id: "mentally_tired", label: "I get mentally tired quickly", icon: "battery.25")
    ]

    let helpsOptions: [OnboardingOption] = [
        OnboardingOption(id: "larger_text", label: "Larger text", icon: "textformat.size.larger"),
        OnboardingOption(id: "more_spacing", label: "More spacing between lines", icon: "arrow.up.and.down.text.horizontal"),
        OnboardingOption(id: "smaller_chunks", label: "Breaking text into smaller chunks", icon: "rectangle.split.3x1"),
        OnboardingOption(id: "one_sentence", label: "Reading one sentence at a time", icon: "text.line.first.and.arrowtriangle.forward"),
        OnboardingOption(id: "listen_while_reading", label: "Listening while reading", icon: "speaker.wave.2"),
        OnboardingOption(id: "highlight_current", label: "Highlighting current text", icon: "highlighter")
    ]

    let studyOptions: [OnboardingOption] = [
        OnboardingOption(id: "quiet_reading", label: "Quiet reading", icon: "book"),
        OnboardingOption(id: "audio_support", label: "Reading with audio support", icon: "headphones"),
        OnboardingOption(id: "short_sessions", label: "Short focused sessions", icon: "timer"),
        OnboardingOption(id: "summaries_first", label: "Structured summaries first", icon: "list.bullet.rectangle")
    ]

    // MARK: - Navigation

    var canAdvanceFromQuestionnaire: Bool {
        !challengeSelections.isEmpty && !helpsSelections.isEmpty && studyPreference != nil
    }

    func nextPage() {
        guard let next = OnboardingPage(rawValue: currentPage.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage = next
        }
    }

    func previousPage() {
        guard let prev = OnboardingPage(rawValue: currentPage.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage = prev
        }
    }

    // MARK: - Toggle Selections

    func toggleChallenge(_ id: String) {
        if challengeSelections.contains(id) {
            challengeSelections.remove(id)
        } else {
            challengeSelections.insert(id)
        }
    }

    func toggleHelps(_ id: String) {
        if helpsSelections.contains(id) {
            helpsSelections.remove(id)
        } else {
            helpsSelections.insert(id)
        }
    }

    func selectStudyPreference(_ id: String) {
        studyPreference = id
    }

    // MARK: - Personalization Logic

    /// Computes personalized settings based on questionnaire responses
    func applyPersonalization() {
        // Start with defaults
        var textSize = 22.0
        var lineSpacing = 8.0
        var letterSpacing = 1.5
        var focusMode = false
        var highlightSentence = false
        var speechRate = 0.45
        var readAloudHighlight = false
        var sentenceChunking = true

        // --- Challenge-based adjustments ---

        if challengeSelections.contains("long_sentences") {
            sentenceChunking = true
            lineSpacing = max(lineSpacing, 12.0)
        }

        if challengeSelections.contains("dense_paragraphs") {
            lineSpacing = max(lineSpacing, 12.0)
            letterSpacing = max(letterSpacing, 2.5)
        }

        if challengeSelections.contains("lose_place") {
            focusMode = true
            highlightSentence = true
        }

        if challengeSelections.contains("read_slowly") {
            speechRate = 0.35
            readAloudHighlight = true
        }

        if challengeSelections.contains("pronunciation") {
            speechRate = 0.30
            readAloudHighlight = true
        }

        if challengeSelections.contains("mentally_tired") {
            textSize = max(textSize, 26.0)
            focusMode = true
        }

        // --- Helps-based adjustments ---

        if helpsSelections.contains("larger_text") {
            textSize = max(textSize, 28.0)
        }

        if helpsSelections.contains("more_spacing") {
            lineSpacing = max(lineSpacing, 14.0)
            letterSpacing = max(letterSpacing, 3.0)
        }

        if helpsSelections.contains("smaller_chunks") {
            sentenceChunking = true
        }

        if helpsSelections.contains("one_sentence") {
            focusMode = true
        }

        if helpsSelections.contains("listen_while_reading") {
            readAloudHighlight = true
            speechRate = min(speechRate, 0.38)
        }

        if helpsSelections.contains("highlight_current") {
            highlightSentence = true
        }

        // --- Study preference adjustments ---

        if studyPreference == "audio_support" {
            readAloudHighlight = true
            speechRate = min(speechRate, 0.40)
        }

        if studyPreference == "short_sessions" {
            focusMode = true
        }

        // --- Persist ---

        prefTextSize = textSize
        prefLineSpacing = lineSpacing
        prefLetterSpacing = letterSpacing
        prefFocusMode = focusMode
        prefHighlightSentence = highlightSentence
        prefSpeechRate = speechRate
        prefReadAloudHighlight = readAloudHighlight
        prefSentenceChunking = sentenceChunking
    }

    // MARK: - Summary Data

    /// List of features that were personalized (for the summary screen)
    var enabledFeatures: [(icon: String, label: String)] {
        var features: [(String, String)] = []

        if prefTextSize > 22.0 {
            features.append(("textformat.size.larger", "Larger text size (\(Int(prefTextSize))pt)"))
        }
        if prefLineSpacing > 8.0 {
            features.append(("arrow.up.and.down.text.horizontal", "Increased line spacing"))
        }
        if prefLetterSpacing > 1.5 {
            features.append(("arrow.left.and.right", "Wider letter spacing"))
        }
        if prefFocusMode {
            features.append(("eye.circle", "Focus Mode enabled"))
        }
        if prefHighlightSentence {
            features.append(("highlighter", "Sentence highlighting on"))
        }
        if prefReadAloudHighlight {
            features.append(("speaker.wave.2", "Read-aloud word tracking"))
        }
        if prefSpeechRate < 0.45 {
            features.append(("gauge.low", "Slower speech rate"))
        }
        if prefSentenceChunking {
            features.append(("rectangle.split.3x1", "Sentence chunking active"))
        }

        if features.isEmpty {
            features.append(("checkmark.circle", "Default balanced settings"))
        }

        return features
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        applyPersonalization()
        onboardingComplete = true
    }
}
