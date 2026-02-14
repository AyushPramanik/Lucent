import SwiftUI

// MARK: - Root Navigation

struct ContentView: View {
    @EnvironmentObject var viewModel: ReadingViewModel

    var body: some View {
        NavigationStack {
            HomeView()
                .navigationDestination(isPresented: $viewModel.showClarityView) {
                    ClarityView()
                        .navigationTitle("Lucent")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    viewModel.stopSpeaking()
                                    viewModel.showClarityView = false
                                } label: {
                                    HStack(spacing: LucentTheme.spacingXS) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Home")
                                            .font(LucentTheme.bodyFont(size: 17))
                                    }
                                    .foregroundColor(LucentTheme.accent)
                                }
                                .accessibilityLabel("Back to Home")
                            }
                        }
                }
        }
    }
}
