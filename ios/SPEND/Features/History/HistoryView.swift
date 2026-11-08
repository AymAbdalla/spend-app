import SwiftUI
import SwiftData

/// Marks the History screen in the Dashboard's navigation path.
struct HistoryDestination: Hashable {}

/// Every saved purchase, newest first, one section per calendar day with that
/// day's total. Read-only: visiting it saves, edits and deletes nothing.
struct HistoryView: View {
    @Query(sort: \Purchase.date, order: .reverse) private var purchases: [Purchase]
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        Group {
            if purchases.isEmpty {
                ContentUnavailableView {
                    Label("No purchases yet.", systemImage: "list.bullet.rectangle")
                } description: {
                    Text("Purchases you save appear here, newest first.")
                }
            } else {
                switch Result(catching: { try DaySections.group(purchases, calendar: calendar) }) {
                case .success(let sections):
                    list(sections)
                case .failure(let error):
                    ContentUnavailableView {
                        Label("History can't be shown", systemImage: "exclamationmark.circle")
                    } description: {
                        Text(error.localizedDescription)
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private func list(_ sections: [DaySection<Purchase>]) -> some View {
        List {
            ForEach(sections, id: \.day) { section in
                Section {
                    ForEach(section.items) { purchase in
                        NavigationLink(value: purchase) {
                            PurchaseRow(purchase: purchase, dateStyle: .time)
                        }
                        .accessibilityIdentifier("historyRow")
                    }
                } header: {
                    header(section)
                }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("historyList")
    }

    private func header(_ section: DaySection<Purchase>) -> some View {
        let key = dayKey(section.day)
        return AmountLine {
            Text(section.day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year()))
                .accessibilityIdentifier("daySection." + key)
        } trailing: {
            Text(Money.format(section.total))
                .fontWeight(.semibold).monospacedDigit().foregroundStyle(.primary)
                .accessibilityIdentifier("dayTotal." + key)
        }
        .textCase(nil)
    }

    /// `yyyy-MM-dd` in the device calendar, for stable accessibility identifiers.
    private func dayKey(_ day: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: day)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
