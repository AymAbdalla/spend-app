import XCTest
import SwiftData
@testable import SPEND

final class MoneyTests: XCTestCase {
    func testDecimalAmountsAreExactCents() throws {
        XCTAssertEqual(try Money.parse("0.10", locale: Locale(identifier: "en_US")), 10)
        XCTAssertEqual(try Money.parse("0.20", locale: Locale(identifier: "en_US")), 20)
        XCTAssertEqual(try Money.parse("12.34", locale: Locale(identifier: "en_US")), 1234)
    }

    func testLocaleSeparatorsAndWhitespace() throws {
        XCTAssertEqual(try Money.parse(" 12,34 \n", locale: Locale(identifier: "de_DE")), 1234)
        XCTAssertEqual(try Money.parse(".50", locale: Locale(identifier: "en_US")), 50)
        XCTAssertEqual(try Money.parse("12", locale: Locale(identifier: "en_US")), 1200)
        XCTAssertEqual(try Money.parse("12.3", locale: Locale(identifier: "en_US")), 1230)
    }

    func testMalformedNonPositiveAndOverPrecisionAmountsAreRejected() {
        for text in ["", " ", "0", "0.00", "-1", "+1", "1.001", "1e2", "NaN", "12abc", "1,234", "1.2.3", "12.", "$12", "１２"] {
            XCTAssertThrowsError(try Money.parse(text, locale: Locale(identifier: "en_US")), text)
        }
    }

    func testCheckedRangeAndNoSilentRounding() throws {
        XCTAssertEqual(try Money.parse("92233720368547758.07", locale: Locale(identifier: "en_US")), Int64.max)
        for text in ["92233720368547758.08", "92233720368547759", String(repeating: "9", count: 100)] {
            XCTAssertThrowsError(try Money.parse(text, locale: Locale(identifier: "en_US")))
        }
    }

    func testFormattingUsesUSDAndExactCents() {
        XCTAssertEqual(Money.format(30, locale: Locale(identifier: "en_US")), "$0.30")
        XCTAssertEqual(Money.format(1234, locale: Locale(identifier: "en_US")), "$12.34")
    }
}

@MainActor
final class PersistenceTests: XCTestCase {
    func testPurchaseSurvivesReopeningDiskStore() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("journal.store")
        var draft = PurchaseDraft()
        draft.date = Date(timeIntervalSince1970: 1_700_000_000)
        draft.amount = "12.34"
        draft.merchant = "  Test cafe  "
        draft.category = .foodAndDrink
        draft.spendingType = .impulse
        draft.notes = "  With a friend  "
        try autoreleasepool {
            let container = try JournalStore.open(at: url)
            try PurchaseWriter.save(draft, in: container.mainContext, locale: Locale(identifier: "en_US"))
        }
        let reopened = try JournalStore.open(at: url)
        let purchases = try reopened.mainContext.fetch(FetchDescriptor<Purchase>())
        XCTAssertEqual(purchases.count, 1)
        guard let purchase = purchases.first else { return }
        XCTAssertEqual(purchase.id, draft.id)
        XCTAssertEqual(purchase.date, draft.date)
        XCTAssertEqual(purchase.amountInCents, 1234)
        XCTAssertEqual(purchase.merchant, "Test cafe")
        XCTAssertEqual(purchase.category, .foodAndDrink)
        XCTAssertEqual(purchase.spendingType, .impulse)
        XCTAssertEqual(purchase.notes, "With a friend")
    }
}
