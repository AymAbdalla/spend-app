import XCTest
import SwiftData
@testable import SPEND

@MainActor
final class RecoveryTests: XCTestCase {
    private func withStore(_ body: (ModelContainer, URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("journal.store")
        try body(JournalStore.open(at: url), url)
    }

    func testHostedUnitTestsHaveNoAppJournalStoreState() {
        XCTAssertNil(AppConfiguration.makeStoreState())
    }

    func testCompleteProtectionIsRequestedForFolderAndCreatedStoreFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("journal.store")
        var requests: [String: FileProtectionType] = [:]
        let container = try JournalStore.open(at: url) { attributes, path in
            requests[path] = attributes[.protectionKey] as? FileProtectionType
            try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
        }
        var draft = PurchaseDraft()
        draft.amount = "12.34"
        draft.merchant = "Protected purchase"
        try PurchaseWriter.save(draft, in: container.mainContext)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("journal.store") }
        XCTAssertTrue(files.contains(url), "The real SQLite store must exist")
        for file in [directory] + files { XCTAssertEqual(requests[file.path], .complete) }
    }

    func testReopeningRequestsCompleteProtectionWithoutLosingExistingPurchase() throws {
        try withStore { container, url in
            var draft = PurchaseDraft()
            draft.amount = "12.34"
            draft.merchant = "Existing purchase"
            try PurchaseWriter.save(draft, in: container.mainContext)
            let directory = url.deletingLastPathComponent()
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { $0.lastPathComponent.hasPrefix("journal.store") }
            for file in [directory] + files {
                try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: file.path)
            }
            var requests: [String: FileProtectionType] = [:]
            let reopened = try JournalStore.open(at: url) { attributes, path in
                requests[path] = attributes[.protectionKey] as? FileProtectionType
                try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
            }
            let purchases = try reopened.mainContext.fetch(FetchDescriptor<Purchase>())
            XCTAssertEqual(purchases.count, 1)
            XCTAssertEqual(purchases.first?.id, draft.id)
            XCTAssertEqual(purchases.first?.merchant, "Existing purchase")
            XCTAssertEqual(purchases.first?.amountInCents, 1234)
            for file in [directory] + files { XCTAssertEqual(requests[file.path], .complete) }
        }
    }

    func testProtectionFailureDoesNotDeleteExistingPurchase() throws {
        try withStore { container, url in
            var draft = PurchaseDraft()
            draft.amount = "12.34"
            draft.merchant = "Existing purchase"
            try PurchaseWriter.save(draft, in: container.mainContext)
            XCTAssertThrowsError(try JournalStore.open(at: url, setFileAttributes: { _, _ in
                throw CocoaError(.fileWriteNoPermission)
            }))
            let reopened = try JournalStore.open(at: url)
            let purchases = try reopened.mainContext.fetch(FetchDescriptor<Purchase>())
            XCTAssertEqual(purchases.count, 1)
            XCTAssertEqual(purchases.first?.id, draft.id)
            XCTAssertEqual(purchases.first?.amountInCents, 1234)
        }
    }

    func testFailedSavePreservesEntryAndRetrySavesExactlyOnce() throws {
        try withStore { container, _ in
            let entry = QuickEntrySession()
            entry.draft.amount = "12.34"
            entry.draft.merchant = "Test cafe"
            XCTAssertFalse(entry.save(in: container.mainContext, commit: { _ in throw CocoaError(.fileWriteOutOfSpace) }))
            XCTAssertNotNil(entry.errorMessage)
            XCTAssertFalse(entry.isSaved)
            XCTAssertEqual(entry.draft.amount, "12.34")
            XCTAssertEqual(entry.draft.merchant, "Test cafe")
            XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Purchase>()), 0)
            XCTAssertTrue(entry.save(in: container.mainContext))
            XCTAssertNil(entry.errorMessage)
            XCTAssertTrue(entry.isSaved)
            XCTAssertFalse(entry.save(in: container.mainContext))
            XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Purchase>()), 1)
        }
    }

    func testLoadFailureRetryRetainsExistingDiskPurchase() throws {
        try withStore { container, url in
            var draft = PurchaseDraft()
            draft.amount = "12.34"
            draft.merchant = "Test cafe"
            try PurchaseWriter.save(draft, in: container.mainContext)
            var fail = true
            let state = StoreState {
                if fail { fail = false; throw CocoaError(.fileReadNoSuchFile) }
                return try JournalStore.open(at: url)
            }
            state.load()
            XCTAssertTrue(state.hasError)
            XCTAssertNil(state.container)
            state.load()
            XCTAssertFalse(state.hasError)
            let recovered = try XCTUnwrap(state.container)
            XCTAssertEqual(try recovered.mainContext.fetchCount(FetchDescriptor<Purchase>()), 1)
        }
    }

    func testSameDraftIsIdempotentAndSeparateIdenticalPurchasesAreAllowed() throws {
        try withStore { container, _ in
            var first = PurchaseDraft()
            first.amount = "1.00"
            first.merchant = "Test cafe"
            try PurchaseWriter.save(first, in: container.mainContext)
            try PurchaseWriter.save(first, in: container.mainContext)
            var second = PurchaseDraft()
            second.amount = first.amount
            second.merchant = first.merchant
            try PurchaseWriter.save(second, in: container.mainContext)
            XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Purchase>()), 2)
        }
    }

    func testInvalidMerchantAndTextLimitsDoNotPersist() throws {
        try withStore { container, _ in
            var draft = PurchaseDraft()
            draft.amount = "1.00"
            draft.merchant = " \n "
            XCTAssertThrowsError(try PurchaseWriter.save(draft, in: container.mainContext))
            draft.merchant = String(repeating: "a", count: 201)
            XCTAssertThrowsError(try PurchaseWriter.save(draft, in: container.mainContext))
            draft.merchant = "Test cafe"
            draft.notes = String(repeating: "n", count: 2_001)
            XCTAssertThrowsError(try PurchaseWriter.save(draft, in: container.mainContext))
            XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Purchase>()), 0)
        }
    }
}
