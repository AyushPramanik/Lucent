import SwiftUI
import Combine

// MARK: - Reading ViewModel

@MainActor
final class ReadingViewModel: ObservableObject {

    // MARK: - Input

    @Published var rawText: String = ""

    // MARK: - Processed Output

    @Published var paragraphs: [ProcessedParagraph] = []
    @Published var density: CognitiveDensity = .low
    @Published var hasContent: Bool = false

    // MARK: - Display Settings

    @Published var letterSpacing: Double = 1.5
    @Published var lineSpacing: Double = 8.0
    @Published var textSize: Double = 22.0

    // MARK: - Modes

    @Published var focusModeEnabled: Bool = false
    @Published var highlightSentenceEnabled: Bool = false
    @Published var focusedSentenceID: UUID? = nil

    // MARK: - Speech

    @Published var speechRate: Double = 0.45
    let speechManager = SpeechManager()

    // MARK: - Navigation

    @Published var showClarityView: Bool = false

    // MARK: - Processing

    /// Run the text processing pipeline on the raw text
    func processText() {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            paragraphs = []
            density = .low
            hasContent = false
            return
        }

        paragraphs = TextProcessor.process(text)
        density = TextProcessor.calculateDensity(paragraphs)
        hasContent = !paragraphs.isEmpty

        // Auto-focus the first sentence if focus mode is on
        if focusModeEnabled, let first = paragraphs.first?.sentences.first {
            focusedSentenceID = first.id
        }
    }

    /// Load text and navigate to clarity view
    func loadText(_ text: String) {
        rawText = text
        processText()
        showClarityView = true
    }

    // MARK: - Speech

    func speakSentence(_ sentence: ProcessedSentence) {
        focusedSentenceID = sentence.id
        speechManager.speak(sentence: sentence.text, rate: speechRate)
    }

    func stopSpeaking() {
        speechManager.stop()
    }

    // MARK: - Focus Navigation

    /// Get all sentence IDs in order
    var allSentenceIDs: [UUID] {
        paragraphs.flatMap { $0.sentences.map { $0.id } }
    }

    /// Move focus to the next sentence
    func focusNextSentence() {
        guard let currentID = focusedSentenceID else {
            focusedSentenceID = allSentenceIDs.first
            return
        }
        let ids = allSentenceIDs
        if let idx = ids.firstIndex(of: currentID), idx + 1 < ids.count {
            focusedSentenceID = ids[idx + 1]
        }
    }

    /// Move focus to the previous sentence
    func focusPreviousSentence() {
        guard let currentID = focusedSentenceID else {
            focusedSentenceID = allSentenceIDs.first
            return
        }
        let ids = allSentenceIDs
        if let idx = ids.firstIndex(of: currentID), idx - 1 >= 0 {
            focusedSentenceID = ids[idx - 1]
        }
    }

    /// Distance of a sentence from the focused sentence (for blur calculation)
    func distanceFromFocus(_ sentenceID: UUID) -> Int {
        let ids = allSentenceIDs
        guard let focusIdx = focusedSentenceID.flatMap({ id in ids.firstIndex(of: id) }),
              let sentIdx = ids.firstIndex(of: sentenceID) else {
            return 0
        }
        return abs(focusIdx - sentIdx)
    }
}
