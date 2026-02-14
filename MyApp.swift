import SwiftUI

@main
struct MyApp: App {
    @StateObject private var viewModel = ReadingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
