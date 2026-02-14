import AVFoundation
import SwiftUI

// MARK: - Speech Manager

@MainActor
final class SpeechManager: NSObject, ObservableObject {

    @Published var isSpeaking: Bool = false
    @Published var currentWordIndex: Int? = nil
    @Published var currentSentenceText: String = ""

    private let synthesizer = AVSpeechSynthesizer()
    private var wordRanges: [(range: Range<String.Index>, index: Int)] = []
    private var spokenText: String = ""

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speak a sentence at the given rate (0.0 – 1.0)
    func speak(sentence: String, rate: Double) {
        stop()

        spokenText = sentence
        currentSentenceText = sentence
        currentWordIndex = nil

        // Pre-compute word indices
        buildWordRanges(for: sentence)

        let utterance = AVSpeechUtterance(string: sentence)
        utterance.rate = Float(rate)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        // Use a calm, natural voice if available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Stop speaking
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentWordIndex = nil
        currentSentenceText = ""
    }

    // MARK: - Private

    private func buildWordRanges(for text: String) {
        wordRanges = []
        var index = 0
        var searchStart = text.startIndex

        while searchStart < text.endIndex {
            // Skip whitespace
            while searchStart < text.endIndex && text[searchStart].isWhitespace {
                searchStart = text.index(after: searchStart)
            }
            guard searchStart < text.endIndex else { break }

            // Find end of word
            var searchEnd = searchStart
            while searchEnd < text.endIndex && !text[searchEnd].isWhitespace {
                searchEnd = text.index(after: searchEnd)
            }

            let range = searchStart..<searchEnd
            wordRanges.append((range: range, index: index))
            index += 1
            searchStart = searchEnd
        }
    }

    private nonisolated func findWordIndex(characterRange: NSRange, in text: String) -> Int? {
        guard let range = Range(characterRange, in: text) else { return nil }
        let midpoint = text.index(range.lowerBound, offsetBy: max(0, text.distance(from: range.lowerBound, to: range.upperBound) / 2))

        // Build word ranges inline for nonisolated context
        var wordIndex = 0
        var searchStart = text.startIndex

        while searchStart < text.endIndex {
            while searchStart < text.endIndex && text[searchStart].isWhitespace {
                searchStart = text.index(after: searchStart)
            }
            guard searchStart < text.endIndex else { break }

            var searchEnd = searchStart
            while searchEnd < text.endIndex && !text[searchEnd].isWhitespace {
                searchEnd = text.index(after: searchEnd)
            }

            if midpoint >= searchStart && midpoint < searchEnd {
                return wordIndex
            }
            wordIndex += 1
            searchStart = searchEnd
        }
        return nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechManager: @preconcurrency AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        let text = utterance.speechString
        let wordIdx = findWordIndex(characterRange: characterRange, in: text)

        Task { @MainActor in
            self.currentWordIndex = wordIdx
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentWordIndex = nil
            self.currentSentenceText = ""
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentWordIndex = nil
            self.currentSentenceText = ""
        }
    }
}
