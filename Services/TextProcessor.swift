import Foundation

// MARK: - Text Processing Engine

struct TextProcessor {

    /// Conjunctions used to break long sentences
    private static let conjunctions: Set<String> = [
        "and", "but", "because", "which", "that",
        "however", "although", "while", "since", "or"
    ]

    /// Maximum words before attempting to break a sentence
    private static let maxSentenceWords = 18

    // MARK: - Public API

    /// Full processing pipeline: raw text -> structured paragraphs
    static func process(_ text: String) -> [ProcessedParagraph] {
        let rawParagraphs = splitIntoParagraphs(text)
        return rawParagraphs.compactMap { rawParagraph -> ProcessedParagraph? in
            let trimmed = rawParagraph.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            let rawSentences = splitIntoSentences(trimmed)
            var allSentences: [ProcessedSentence] = []

            for rawSentence in rawSentences {
                let sentence = ProcessedSentence(text: rawSentence)
                if sentence.isLong {
                    let broken = breakLongSentence(sentence.text)
                    allSentences.append(contentsOf: broken.map { ProcessedSentence(text: $0) })
                } else if !sentence.text.isEmpty {
                    allSentences.append(sentence)
                }
            }

            guard !allSentences.isEmpty else { return nil }
            return ProcessedParagraph(sentences: allSentences, rawText: trimmed)
        }
    }

    /// Calculate cognitive density from processed paragraphs
    static func calculateDensity(_ paragraphs: [ProcessedParagraph]) -> CognitiveDensity {
        guard !paragraphs.isEmpty else { return .low }

        let allSentences = paragraphs.flatMap { $0.sentences }
        guard !allSentences.isEmpty else { return .low }

        let avgSentenceLength = Double(allSentences.reduce(0) { $0 + $1.wordCount }) / Double(allSentences.count)
        let avgWordsPerParagraph = Double(paragraphs.reduce(0) { $0 + $1.wordCount }) / Double(paragraphs.count)

        // Heuristic scoring
        let sentenceScore: Double
        if avgSentenceLength <= 10 {
            sentenceScore = 1.0
        } else if avgSentenceLength <= 18 {
            sentenceScore = 2.0
        } else {
            sentenceScore = 3.0
        }

        let paragraphScore: Double
        if avgWordsPerParagraph <= 40 {
            paragraphScore = 1.0
        } else if avgWordsPerParagraph <= 80 {
            paragraphScore = 2.0
        } else {
            paragraphScore = 3.0
        }

        let combined = (sentenceScore + paragraphScore) / 2.0

        if combined <= 1.5 {
            return .low
        } else if combined <= 2.3 {
            return .moderate
        } else {
            return .high
        }
    }

    // MARK: - Internal Helpers

    /// Split text into paragraphs on double newlines or multiple newlines
    static func splitIntoParagraphs(_ text: String) -> [String] {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        let paragraphs = normalized.components(separatedBy: "\n\n")
        return paragraphs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Split a paragraph into individual sentences
    static func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        let cleaned = text.replacingOccurrences(of: "\n", with: " ")

        // Use a simple approach: split at sentence-ending punctuation followed by a space or end
        var current = ""
        let chars = Array(cleaned)
        let endPunctuation: Set<Character> = [".", "!", "?"]

        for i in 0..<chars.count {
            current.append(chars[i])

            if endPunctuation.contains(chars[i]) {
                // Check if next char is space or end of string (avoid splitting on abbreviations like "Dr.")
                let isEnd = i == chars.count - 1
                let nextIsSpace = i + 1 < chars.count && chars[i + 1] == " "
                let nextIsUpper = i + 2 < chars.count && chars[i + 2].isUppercase

                if isEnd || (nextIsSpace && (nextIsUpper || i + 2 >= chars.count)) {
                    let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        sentences.append(trimmed)
                    }
                    current = ""
                }
            }
        }

        // Don't lose remaining text
        let remaining = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !remaining.isEmpty {
            sentences.append(remaining)
        }

        return sentences
    }

    /// Break a long sentence at conjunctions into shorter fragments
    static func breakLongSentence(_ sentence: String) -> [String] {
        let words = sentence.split(separator: " ").map(String.init)
        guard words.count > maxSentenceWords else { return [sentence] }

        var fragments: [String] = []
        var currentFragment: [String] = []

        for word in words {
            let lowered = word.lowercased().trimmingCharacters(in: .punctuationCharacters)

            if conjunctions.contains(lowered) && currentFragment.count >= 5 {
                // End current fragment and start new one with the conjunction
                let fragment = currentFragment.joined(separator: " ")
                fragments.append(fragment)
                currentFragment = [word]
            } else {
                currentFragment.append(word)
            }
        }

        // Append the last fragment
        if !currentFragment.isEmpty {
            let fragment = currentFragment.joined(separator: " ")
            fragments.append(fragment)
        }

        // If we couldn't break it meaningfully, return original
        if fragments.count <= 1 {
            return [sentence]
        }

        return fragments
    }
}
