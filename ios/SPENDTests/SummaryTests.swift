import XCTest
@testable import SPEND

final class SummaryTests: XCTestCase {
    private func date(_ value: String) -> Date { ISO8601DateFormatter().date(from: value)! }
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }
    private func record(_ date: String, _ cents: Int64,
                        _ category: PurchaseCategory = .other,
                        _ type: SpendingType = .planned) -> SpendingRecord {
        SpendingRecord(date: self.date(date), amountInCents: cents, category: category, spendingType: type)
    }

    func testDayWeekAndMonthAcrossYearBoundaryExcludeFuture() throws {
        let records = [record("2026-12-27T23:59:59Z", 100), record("2026-12-28T00:00:00Z", 200),
                       record("2026-12-31T23:59:59Z", 300), record("2027-01-01T00:00:00Z", 400),
                       record("2027-01-01T12:00:00Z", 500), record("2027-01-01T12:00:01Z", 900),
                       record("2027-01-02T00:00:00Z", 1000)]
        let summary = try SpendingSummary.calculate(records, now: date("2027-01-01T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(summary.today, 900)
        XCTAssertEqual(summary.week, 1400)
        XCTAssertEqual(summary.month, 900)
    }

    func testMonthlyBreakdownsReconcileAndTenPlusTwentyCentsIsThirty() throws {
        let records = [record("2026-11-01T10:00:00Z", 10, .foodAndDrink, .planned),
                       record("2026-11-06T10:00:00Z", 20, .foodAndDrink, .impulse),
                       record("2026-11-06T10:00:00Z", 100, .transport, .planned),
                       record("2026-10-31T23:59:59Z", 9999, .shopping, .impulse)]
        let summary = try SpendingSummary.calculate(records, now: date("2026-11-06T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(summary.today, 120)
        XCTAssertEqual(summary.month, 130)
        XCTAssertEqual(summary.categories[.foodAndDrink], 30)
        XCTAssertEqual(summary.categories[.transport], 100)
        XCTAssertNil(summary.categories[.shopping])
        XCTAssertEqual(summary.types[.planned], 110)
        XCTAssertEqual(summary.types[.impulse], 20)
    }

    func testLocalDayUsesDaylightSavingBoundary() throws {
        var calendar = self.calendar
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let records = [record("2027-03-14T04:59:59Z", 900), record("2027-03-14T05:00:00Z", 10),
                       record("2027-03-15T03:59:59Z", 20), record("2027-03-15T04:00:00Z", 800)]
        let summary = try SpendingSummary.calculate(records, now: date("2027-03-15T03:59:59Z"), calendar: calendar)
        XCTAssertEqual(summary.today, 30)
    }

    func testLeapFebruaryAndExactMonthStart() throws {
        let records = [record("2028-02-01T00:00:00Z", 10), record("2028-02-29T00:00:00Z", 20),
                       record("2028-03-01T00:00:00Z", 40)]
        let february = try SpendingSummary.calculate(records, now: date("2028-02-29T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(february.month, 30)
        XCTAssertEqual(february.today, 20)
        let march = try SpendingSummary.calculate(records, now: date("2028-03-01T00:00:00Z"), calendar: calendar)
        XCTAssertEqual(march.month, 40)
        XCTAssertEqual(march.today, 40)
    }

    func testWeekStartFollowsCalendarPreference() throws {
        let records = [record("2026-11-01T00:00:00Z", 100), record("2026-11-02T00:00:00Z", 20)]
        var sunday = calendar
        sunday.firstWeekday = 1
        sunday.minimumDaysInFirstWeek = 1
        let mondayResult = try SpendingSummary.calculate(records, now: date("2026-11-02T12:00:00Z"), calendar: calendar)
        let sundayResult = try SpendingSummary.calculate(records, now: date("2026-11-02T12:00:00Z"), calendar: sunday)
        XCTAssertEqual(mondayResult.week, 20)
        XCTAssertEqual(sundayResult.week, 120)
    }

    func testOverflowAndInvalidStoredAmountAreReported() throws {
        let now = date("2026-11-06T12:00:00Z")
        XCTAssertThrowsError(try SpendingSummary.calculate([record("2026-11-06T00:00:00Z", .max),
                                                           record("2026-11-06T00:00:00Z", 1)], now: now, calendar: calendar))
        XCTAssertThrowsError(try SpendingSummary.calculate([record("2026-11-06T00:00:00Z", -1)], now: now, calendar: calendar))
    }

    func testEmptyJournalHasZeroTotals() throws {
        let summary = try SpendingSummary.calculate([], now: date("2026-11-06T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(summary.today, 0)
        XCTAssertEqual(summary.week, 0)
        XCTAssertEqual(summary.month, 0)
        XCTAssertTrue(summary.categories.isEmpty)
    }
}
