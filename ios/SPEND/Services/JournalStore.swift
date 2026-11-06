import Foundation
import SwiftData

@MainActor
enum JournalStore {
    static func openJournal(in supportDirectory: URL,
                            setFileAttributes: ([FileAttributeKey: Any], String) throws -> Void = {
                                try FileManager.default.setAttributes($0, ofItemAtPath: $1)
                            },
                            copyItem: (URL, URL) throws -> Void = {
                                try FileManager.default.copyItem(at: $0, to: $1)
                            }) throws -> ModelContainer {
        let manager = FileManager.default
        try manager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
        let directory = supportDirectory.appendingPathComponent("Journal", isDirectory: true)
        let url = directory.appendingPathComponent("journal.store")
        let legacy = supportDirectory.appendingPathComponent("journal.store")
        if !manager.fileExists(atPath: url.path), manager.fileExists(atPath: legacy.path) {
            let staging = supportDirectory.appendingPathComponent("Journal-Migration-" + UUID().uuidString, isDirectory: true)
            defer { try? manager.removeItem(at: staging) }
            let stagedStore = staging.appendingPathComponent("journal.store")
            try protectStore(at: stagedStore, setFileAttributes: setFileAttributes)
            for name in ["journal.store", "journal.store-wal", "journal.store-shm"] {
                let source = supportDirectory.appendingPathComponent(name)
                if manager.fileExists(atPath: source.path) {
                    try copyItem(source, staging.appendingPathComponent(name))
                }
            }
            try protectStore(at: stagedStore, setFileAttributes: setFileAttributes)
            try manager.moveItem(at: staging, to: directory)
        }
        return try open(at: url, setFileAttributes: setFileAttributes)
    }

    static func open(at url: URL,
                     setFileAttributes: ([FileAttributeKey: Any], String) throws -> Void = {
                         try FileManager.default.setAttributes($0, ofItemAtPath: $1)
                     }) throws -> ModelContainer {
        try protectStore(at: url, setFileAttributes: setFileAttributes)
        let schema = Schema([Purchase.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = false
        try protectStore(at: url, setFileAttributes: setFileAttributes)
        return container
    }

    private static func protectStore(at url: URL,
                                     setFileAttributes: ([FileAttributeKey: Any], String) throws -> Void) throws {
        let manager = FileManager.default
        let directory = url.deletingLastPathComponent()
        let attributes: [FileAttributeKey: Any] = [.protectionKey: FileProtectionType.complete]
        try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: attributes)
        try setFileAttributes(attributes, directory.path)
        for path in [url.path, url.path + "-wal", url.path + "-shm"] where manager.fileExists(atPath: path) {
            try setFileAttributes(attributes, path)
        }
    }
}

struct PurchaseDraft {
    let id = UUID()
    var date = Date()
    var amount = ""
    var merchant = ""
    var category: PurchaseCategory = .other
    var spendingType: SpendingType = .planned
    var notes = ""
}

@MainActor
enum PurchaseWriter {
    static func save(_ draft: PurchaseDraft, in context: ModelContext,
                     locale: Locale = .current,
                     commit: (ModelContext) throws -> Void = { try $0.save() }) throws {
        let amount = try Money.parse(draft.amount, locale: locale)
        let merchant = draft.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !merchant.isEmpty else { throw JournalError.merchantRequired }
        guard merchant.count <= 200, notes.count <= 2_000 else { throw JournalError.textTooLong }
        let id = draft.id
        let existing = FetchDescriptor<Purchase>(predicate: #Predicate { $0.id == id })
        guard try context.fetchCount(existing) == 0 else { return }
        let purchase = Purchase(id: id, date: draft.date, merchant: merchant,
                                amountInCents: amount, category: draft.category,
                                spendingType: draft.spendingType, notes: notes.isEmpty ? nil : notes)
        context.insert(purchase)
        do {
            try commit(context)
        } catch {
            context.rollback()
            throw error
        }
    }
}
