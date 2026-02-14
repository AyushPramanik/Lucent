import Foundation

// MARK: - Processed Text Models

struct ProcessedSentence: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let words: [String]
    var wordCount: Int { words.count }
    var isLong: Bool { wordCount > 18 }

    init(text: String) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.words = self.text
            .split(separator: " ")
            .map(String.init)
    }

    static func == (lhs: ProcessedSentence, rhs: ProcessedSentence) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProcessedParagraph: Identifiable, Equatable {
    let id = UUID()
    let sentences: [ProcessedSentence]
    let rawText: String

    var wordCount: Int {
        sentences.reduce(0) { $0 + $1.wordCount }
    }

    var averageSentenceLength: Double {
        guard !sentences.isEmpty else { return 0 }
        return Double(wordCount) / Double(sentences.count)
    }

    static func == (lhs: ProcessedParagraph, rhs: ProcessedParagraph) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Cognitive Density

enum CognitiveDensity: String {
    case low = "Low Density"
    case moderate = "Moderate Density"
    case high = "High Density"

    var description: String { rawValue }

    var accessibilityLabel: String {
        switch self {
        case .low:
            return "Low cognitive density. This text is easy to read."
        case .moderate:
            return "Moderate cognitive density. This text has average complexity."
        case .high:
            return "High cognitive density. This text may require extra focus."
        }
    }
}
