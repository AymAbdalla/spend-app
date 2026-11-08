import Observation

/// Remembers that the "Log a purchase" shortcut asked to open Quick Entry.
/// iOS can run the shortcut before any screen exists, so one shared instance
/// lives as long as the app. It holds a single flag, so repeated requests
/// collapse into one, and it never touches the journal.
@MainActor @Observable
final class QuickEntryRequest {
    static let shared = QuickEntryRequest()
    private(set) var isPending = false

    func request() { isPending = true }
    func markHandled() { isPending = false }
}
