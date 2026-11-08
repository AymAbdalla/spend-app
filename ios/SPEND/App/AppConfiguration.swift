import SwiftUI
import SwiftData

@MainActor
enum AppConfiguration {
    private static var testStoreID: UUID? {
        #if DEBUG
        if let value = argument(after: "-journal-test-store") { return UUID(uuidString: value) }
        #endif
        return nil
    }

    static func makeStoreState() -> StoreState? {
        let isHostedUnitTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil
        if isHostedUnitTest && testStoreID == nil { return nil }
        var failFirst = false
        #if DEBUG
        failFirst = testStoreID != nil && ProcessInfo.processInfo.arguments.contains("-fail-initial-load")
        #endif
        return StoreState {
            if failFirst {
                failFirst = false
                throw CocoaError(.fileReadUnknown)
            }
            let support = try FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask, appropriateFor: nil, create: true)
            let directory = testStoreID.map { support.appendingPathComponent("UITests/" + $0.uuidString) } ?? support
            let container = try JournalStore.openJournal(in: directory)
            try seedHistoryFixtureForUITests(in: container)
            return container
        }
    }

    /// DEBUG UI tests only. With the test store and `-seed-history-fixture`,
    /// saves four synthetic purchases on fixed calendar dates into an empty test
    /// store through the normal writer, so History tests see the same day
    /// sections in any time zone and on any run date. A store that already has
    /// purchases is left alone, and Release builds don't contain the argument.
    private static func seedHistoryFixtureForUITests(in container: ModelContainer) throws {
        #if DEBUG
        guard testStoreID != nil, ProcessInfo.processInfo.arguments.contains("-seed-history-fixture") else { return }
        let context = container.mainContext
        guard try context.fetchCount(FetchDescriptor<Purchase>()) == 0 else { return }
        let calendar = Calendar.autoupdatingCurrent
        func moment(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
        }
        let fixtures: [(Date, String, String, PurchaseCategory, SpendingType, String)] = [
            (moment(2026, 1, 15, 9, 5), "Corner bakery", "4.50", .foodAndDrink, .impulse, ""),
            (moment(2026, 1, 15, 18, 40), "Weekly grocer", "32.10", .groceries, .planned, "Weekly shop"),
            (moment(2026, 1, 14, 12, 0), "Bus fare", "2.75", .transport, .planned, ""),
            (moment(2030, 6, 1, 10, 0), "Festival ticket", "60.00", .entertainment, .planned, ""),
        ]
        for (date, merchant, amount, category, type, notes) in fixtures {
            var draft = PurchaseDraft()
            draft.date = date
            draft.amount = amount
            draft.merchant = merchant
            draft.category = category
            draft.spendingType = type
            draft.notes = notes
            try PurchaseWriter.save(draft, in: context, locale: Locale(identifier: "en_US"))
        }
        #endif
    }

    static func makeCommit() -> (ModelContext) throws -> Void {
        var failFirst = false
        #if DEBUG
        failFirst = testStoreID != nil && ProcessInfo.processInfo.arguments.contains("-fail-next-save")
        #endif
        return { context in
            if failFirst {
                failFirst = false
                throw CocoaError(.fileWriteOutOfSpace)
            }
            try context.save()
        }
    }

    /// DEBUG UI tests only. The Simulator can't press the Action Button for a
    /// shortcut, so tests run the real "Log a purchase" intent from inside the
    /// app: once from the app's initializer, before any screen exists, or each
    /// time the app becomes active.
    static func runShortcutForUITests(atLaunch: Bool) {
        #if DEBUG
        let flag = atLaunch ? "-run-log-purchase-at-launch" : "-run-log-purchase-on-activate"
        guard testStoreID != nil, ProcessInfo.processInfo.arguments.contains(flag) else { return }
        Task { _ = try? await LogPurchaseIntent().perform() }
        #endif
    }

    static var colorScheme: ColorScheme? {
        #if DEBUG
        if testStoreID != nil, argument(after: "-ui-appearance") == "dark" { return .dark }
        #endif
        return nil
    }

    private static func argument(after name: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: name), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
}
