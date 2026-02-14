import SwiftUI
import UIKit

// MARK: - Text Input View

struct TextInputView: View {
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: LucentTheme.spacingL) {

                // Instructions
                Text("Paste or type your slide text below.")
                    .font(LucentTheme.bodyFont(size: 17))
                    .foregroundColor(LucentTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, LucentTheme.spacingM)

                // Text Editor
                TextEditor(text: $inputText)
                    .focused($isEditorFocused)
                    .font(LucentTheme.bodyFont(size: 18))
                    .foregroundColor(LucentTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(LucentTheme.spacingM)
                    .background(
                        RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                            .fill(LucentTheme.softWhite)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LucentTheme.cornerRadius)
                            .stroke(LucentTheme.divider, lineWidth: 1)
                    )
                    .padding(.horizontal, LucentTheme.spacingM)
                    .accessibilityLabel("Text input area")
                    .accessibilityHint("Paste or type your slide content here")

                // Action Buttons
                HStack(spacing: LucentTheme.spacingM) {
                    // Paste from Clipboard
                    Button {
                        if let clipboardText = UIPasteboard.general.string {
                            inputText = clipboardText
                        }
                    } label: {
                        HStack(spacing: LucentTheme.spacingS) {
                            Image(systemName: "doc.on.clipboard")
                            Text("Paste from Clipboard")
                        }
                    }
                    .buttonStyle(LucentSecondaryButtonStyle())
                    .accessibilityHint("Pastes text from your clipboard into the editor")

                    // Process Button
                    Button {
                        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSubmit(trimmed)
                        dismiss()
                    } label: {
                        HStack(spacing: LucentTheme.spacingS) {
                            Image(systemName: "sparkles")
                            Text("Process Text")
                        }
                    }
                    .buttonStyle(LucentPrimaryButtonStyle())
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    .accessibilityHint("Processes the entered text for clarity reading")
                }
                .padding(.horizontal, LucentTheme.spacingM)
                .padding(.bottom, LucentTheme.spacingL)
            }
            .padding(.top, LucentTheme.spacingM)
            .background(LucentTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Paste Slide Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(LucentTheme.accent)
                }
            }
            .onAppear {
                isEditorFocused = true
            }
        }
    }
}
