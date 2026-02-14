import SwiftUI
import UniformTypeIdentifiers

// MARK: - PDF Import View

struct PDFImportView: View {
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var extractedText: String = ""
    @State private var showFilePicker: Bool = true
    @State private var errorMessage: String? = nil
    @State private var hasExtractedText: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: LucentTheme.spacingL) {
                if hasExtractedText {
                    // Preview extracted text
                    VStack(alignment: .leading, spacing: LucentTheme.spacingS) {
                        Text("Extracted Text Preview")
                            .font(LucentTheme.bodyFontMedium(size: 17))
                            .foregroundColor(LucentTheme.textPrimary)

                        Text("\(wordCount) words found")
                            .font(LucentTheme.caption)
                            .foregroundColor(LucentTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, LucentTheme.spacingM)

                    // Text preview
                    ScrollView {
                        Text(extractedText)
                            .font(LucentTheme.bodyFont(size: 16))
                            .foregroundColor(LucentTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(LucentTheme.spacingM)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                            .fill(LucentTheme.softWhite)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                            .stroke(LucentTheme.divider, lineWidth: 1)
                    )
                    .padding(.horizontal, LucentTheme.spacingM)
                    .accessibilityLabel("Preview of extracted PDF text")

                    // Actions
                    HStack(spacing: LucentTheme.spacingM) {
                        Button {
                            showFilePicker = true
                        } label: {
                            HStack(spacing: LucentTheme.spacingS) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Choose Another")
                            }
                        }
                        .buttonStyle(LucentSecondaryButtonStyle())

                        Button {
                            onSubmit(extractedText)
                            dismiss()
                        } label: {
                            HStack(spacing: LucentTheme.spacingS) {
                                Image(systemName: "checkmark.circle")
                                Text("Use This Text")
                            }
                        }
                        .buttonStyle(LucentPrimaryButtonStyle())
                    }
                    .padding(.horizontal, LucentTheme.spacingM)
                    .padding(.bottom, LucentTheme.spacingL)

                } else if let error = errorMessage {
                    // Error state
                    Spacer()
                    VStack(spacing: LucentTheme.spacingM) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(LucentTheme.densityModerate)

                        Text(error)
                            .font(LucentTheme.bodyFont(size: 17))
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            errorMessage = nil
                            showFilePicker = true
                        }
                        .buttonStyle(LucentPrimaryButtonStyle())
                        .frame(maxWidth: 200)
                    }
                    .padding(LucentTheme.spacingXL)
                    Spacer()
                } else {
                    // Loading / waiting
                    Spacer()
                    VStack(spacing: LucentTheme.spacingM) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 48))
                            .foregroundColor(LucentTheme.accent.opacity(0.5))
                        Text("Select a PDF to extract text")
                            .font(LucentTheme.bodyFont(size: 17))
                            .foregroundColor(LucentTheme.textSecondary)
                    }
                    Spacer()
                }
            }
            .padding(.top, LucentTheme.spacingM)
            .background(LucentTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Import PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(LucentTheme.accent)
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }

    private var wordCount: Int {
        extractedText.split(separator: " ").count
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                errorMessage = "No file was selected."
                return
            }

            // Start security-scoped access
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Unable to access the selected file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            if let text = PDFExtractor.extractText(from: url),
               !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                extractedText = text
                hasExtractedText = true
                errorMessage = nil
            } else {
                errorMessage = "Could not extract text from this PDF.\nThe file may contain only images."
            }

        case .failure:
            errorMessage = "Failed to open the file picker."
        }
    }
}
