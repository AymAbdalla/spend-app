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
            return try JournalStore.openJournal(in: directory)
        }
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
