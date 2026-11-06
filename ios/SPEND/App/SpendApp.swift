import SwiftUI
import SwiftData

@main @MainActor
struct SpendApp: App {
    @State private var store = AppConfiguration.makeStoreState()
    private let commit = AppConfiguration.makeCommit()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = store.container {
                    DashboardView(commit: commit)
                        .modelContainer(container)
                } else if store.hasError {
                    ContentUnavailableView {
                        Label("Your journal couldn't open", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("Your saved data hasn't been removed. Try opening it again.")
                    } actions: {
                        Button("Try again") { store.load() }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("retryStore")
                    }
                } else {
                    ProgressView("Opening your journal")
                }
            }
            .preferredColorScheme(AppConfiguration.colorScheme)
            .task { store.load() }
        }
    }
}
