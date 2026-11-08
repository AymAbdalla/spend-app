import XCTest
@testable import SPEND

final class DaySectionsTests: XCTestCase {
    private func date(_ value: String) -> Date { ISO8601DateFormatter().date(from: value)! }
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    private func record(_ date: String, _ cents: Int64) -> SpendingRecord {
        SpendingRecord(date: self.date(date), amountInCents: cents, category: .other, spendingType: .planned)
    }

    /// The plan's seed fixture, given out of order: day totals $60.00, $36.60
    /// and $2.75, newest day first, and the 2030 purchase is included.
    func testDaysNewestFirstAndItemsNewestFirstWithinADayIncludingFutureDates() throws {
        let records = [record("2026-01-15T09:05:00Z", 450), record("2026-01-14T12:00:00Z", 275),
                       record("2030-06-01T10:00:00Z", 6000), record("2026-01-15T18:40:00Z", 3210)]
        let sections = try DaySections.group(records, calendar: utc)
        XCTAssertEqual(sections.map(\.day),
                       [date("2030-06-01T00:00:00Z"), date("2026-01-15T00:00:00Z"), date("2026-01-14T00:00:00Z")])
        XCTAssertEqual(sections.map(\.total), [6000, 3660, 275])
        XCTAssertEqual(sections.map { $0.items.map(\.amountInCents) }, [[6000], [3210, 450], [275]])
    }

    func testTenPlusTwentyCentsIsThirty() throws {
        let sections = try DaySections.group([record("2026-11-06T10:00:00Z", 10),
                                              record("2026-11-06T11:00:00Z", 20)], calendar: utc)
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.total, 30)
    }

    /// 2027-03-14 is the spring-forward day in New York: local midnight is
    /// 05:00Z before the change and 04:00Z after it.
    func testDayBoundaryFollowsTheCalendarTimeZoneAcrossDaylightSaving() throws {
        var newYork = utc
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        let records = [record("2027-03-14T04:59:59Z", 100), record("2027-03-14T05:00:00Z", 200),
                       record("2027-03-15T03:59:59Z", 300), record("2027-03-15T04:00:00Z", 400)]
        let sections = try DaySections.group(records, calendar: newYork)
        XCTAssertEqual(sections.map(\.day),
                       [date("2027-03-15T04:00:00Z"), date("2027-03-14T05:00:00Z"), date("2027-03-13T05:00:00Z")])
        XCTAssertEqual(sections.map(\.total), [400, 500, 100])
    }

    func testYearBoundarySplitsIntoTwoDays() throws {
        let sections = try DaySections.group([record("2026-12-31T23:59:59Z", 100),
                                              record("2027-01-01T00:00:00Z", 200)], calendar: utc)
        XCTAssertEqual(sections.map(\.day), [date("2027-01-01T00:00:00Z"), date("2026-12-31T00:00:00Z")])
        XCTAssertEqual(sections.map(\.total), [200, 100])
    }

    func testEmptyInputGivesNoSections() throws {
        XCTAssertTrue(try DaySections.group([SpendingRecord](), calendar: utc).isEmpty)
    }

    func testOverflowingDayTotalIsReported() {
        XCTAssertThrowsError(try DaySections.group([record("2026-11-06T00:00:00Z", .max),
                                                    record("2026-11-06T01:00:00Z", 1)], calendar: utc)) { error in
            XCTAssertEqual(error as? JournalError, .totalTooLarge)
        }
    }

    func testNonPositiveAmountIsReported() {
        for cents: Int64 in [0, -1] {
            XCTAssertThrowsError(try DaySections.group([record("2026-11-06T00:00:00Z", cents)], calendar: utc)) { error in
                XCTAssertEqual(error as? JournalError, .invalidRecord)
            }
        }
    }
}
