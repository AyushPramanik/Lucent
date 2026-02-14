import PDFKit

// MARK: - PDF Text Extraction

struct PDFExtractor {

    /// Extract all text content from a PDF file at the given URL
    static func extractText(from url: URL) -> String? {
        guard let document = PDFDocument(url: url) else { return nil }

        var fullText = ""
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                if !fullText.isEmpty {
                    fullText += "\n\n"
                }
                fullText += pageText
            }
        }

        return fullText.isEmpty ? nil : fullText
    }
}
