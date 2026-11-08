import Foundation

/// Anything with a date and an amount in cents. `Purchase` and
/// `SpendingRecord` already have both fields, so History can group either.
protocol DatedAmount {
    var date: Date { get }
    var amountInCents: Int64 { get }
}

extension Purchase: DatedAmount {}
extension SpendingRecord: DatedAmount {}

/// One calendar day of purchases: the day's start in the given calendar, the
/// day's total in cents and its items, newest first.
struct DaySection<Item: DatedAmount> {
    let day: Date
    fileprivate(set) var total: Int64
    fileprivate(set) var items: [Item]
}

enum DaySections {
    /// Groups items by calendar day, newest day first and newest item first
    /// within a day. Throws `JournalError.totalTooLarge` when a day's total
    /// overflows and `JournalError.invalidRecord` for a non-positive amount,
    /// the same errors `SpendingSummary` reports.
    static func group<Item: DatedAmount>(_ items: [Item], calendar: Calendar) throws -> [DaySection<Item>] {
        var sections: [DaySection<Item>] = []
        for item in items.sorted(by: { $0.date > $1.date }) {
            guard item.amountInCents > 0 else { throw JournalError.invalidRecord }
            let day = calendar.startOfDay(for: item.date)
            if let index = sections.indices.last, sections[index].day == day {
                sections[index].total = try add(sections[index].total, item.amountInCents)
                sections[index].items.append(item)
            } else {
                sections.append(DaySection(day: day, total: item.amountInCents, items: [item]))
            }
        }
        return sections
    }

    private static func add(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
        let (total, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow else { throw JournalError.totalTooLarge }
        return total
    }
}
