import SwiftUI
import SwiftData

@main @MainActor
struct SpendApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = AppConfiguration.makeStoreState()
    private let commit = AppConfiguration.makeCommit()

    init() { AppConfiguration.runShortcutForUITests(atLaunch: true) }

    var body: some Scene {
        WindowGroup {
            if let store {
                journalContent(store)
                    .preferredColorScheme(AppConfiguration.colorScheme)
                    .task { store.load() }
            } else {
                Color.clear
            }
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { AppConfiguration.runShortcutForUITests(atLaunch: false) }
        }
    }

    private func journalContent(_ store: StoreState) -> some View {
        Group {
            if let container = store.container {
                DashboardView(commit: commit, entryRequest: .shared)
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
    }
}
