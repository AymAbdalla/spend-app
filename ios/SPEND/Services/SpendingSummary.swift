import Foundation

struct SpendingSummary {
    var today: Int64 = 0
    var week: Int64 = 0
    var month: Int64 = 0
    var categories: [PurchaseCategory: Int64] = [:]
    var types: [SpendingType: Int64] = [:]

    static func calculate(_ records: [SpendingRecord], now: Date,
                          calendar: Calendar) throws -> SpendingSummary {
        guard let day = calendar.dateInterval(of: .day, for: now),
              let week = calendar.dateInterval(of: .weekOfYear, for: now),
              let month = calendar.dateInterval(of: .month, for: now) else {
            throw JournalError.invalidRecord
        }
        var summary = SpendingSummary()
        for record in records where record.date <= now {
            guard record.amountInCents > 0 else { throw JournalError.invalidRecord }
            if record.date >= day.start && record.date < day.end {
                summary.today = try add(summary.today, record.amountInCents)
            }
            if record.date >= week.start && record.date < week.end {
                summary.week = try add(summary.week, record.amountInCents)
            }
            if record.date >= month.start && record.date < month.end {
                summary.month = try add(summary.month, record.amountInCents)
                summary.categories[record.category] = try add(summary.categories[record.category, default: 0], record.amountInCents)
                summary.types[record.spendingType] = try add(summary.types[record.spendingType, default: 0], record.amountInCents)
            }
        }
        return summary
    }

    private static func add(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
        let (total, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow else { throw JournalError.totalTooLarge }
        return total
    }
}
