import SwiftUI

// MARK: - Home Screen

struct HomeView: View {
    @EnvironmentObject var viewModel: ReadingViewModel

    @State private var showTextInput = false
    @State private var showPDFImport = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.18)

                    // MARK: - Hero Section
                    VStack(spacing: LucentTheme.spacingM) {
                        // App icon
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 56))
                            .foregroundColor(LucentTheme.accent)
                            .accessibilityHidden(true)

                        // Title
                        Text("Lucent")
                            .font(LucentTheme.title)
                            .foregroundColor(LucentTheme.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        // Subtitle
                        Text("Designed for dyslexia. Built for clarity.")
                            .font(LucentTheme.subtitle)
                            .foregroundColor(LucentTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, LucentTheme.spacingXXL)

                    // MARK: - Action Buttons
                    VStack(spacing: LucentTheme.spacingM) {
                        Button {
                            showTextInput = true
                        } label: {
                            HStack(spacing: LucentTheme.spacingS) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                Text("Paste Slide Text")
                            }
                        }
                        .buttonStyle(LucentPrimaryButtonStyle())
                        .accessibilityHint("Opens a text editor to paste slide content")

                        Button {
                            showPDFImport = true
                        } label: {
                            HStack(spacing: LucentTheme.spacingS) {
                                Image(systemName: "doc.richtext")
                                    .font(.system(size: 20))
                                Text("Import PDF")
                            }
                        }
                        .buttonStyle(LucentSecondaryButtonStyle())
                        .accessibilityHint("Opens a file picker to import a PDF document")
                    }
                    .frame(maxWidth: 400)

                    Spacer()
                        .frame(height: LucentTheme.spacingXXL)

                    // MARK: - Feature hints
                    HStack(spacing: LucentTheme.spacingXL) {
                        FeatureHint(icon: "textformat.size", label: "Adjustable\nTypography")
                        FeatureHint(icon: "speaker.wave.2", label: "Read\nAloud")
                        FeatureHint(icon: "eye", label: "Focus\nMode")
                    }
                    .padding(.top, LucentTheme.spacingL)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LucentTheme.spacingXL)
            }
        }
        .background(LucentTheme.creamBackground.ignoresSafeArea())
        .sheet(isPresented: $showTextInput) {
            TextInputView { text in
                viewModel.loadText(text)
            }
        }
        .sheet(isPresented: $showPDFImport) {
            PDFImportView { text in
                viewModel.loadText(text)
            }
        }
    }
}

// MARK: - Feature Hint Pill

private struct FeatureHint: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: LucentTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(LucentTheme.accent)
                .frame(width: 48, height: 48)
                .background(LucentTheme.accentLight)
                .clipShape(Circle())

            Text(label)
                .font(LucentTheme.caption)
                .foregroundColor(LucentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
