import SwiftUI

/// Leading content with trailing content on one line; stacked, leading-aligned,
/// at accessibility text sizes so long amounts and names stay readable. Both
/// sides keep their natural height, because inside a List row a long merchant
/// name otherwise truncated ("Festival ti…") instead of wrapping.
struct AmountLine<Leading: View, Trailing: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    private let leading: Leading
    private let trailing: Trailing

    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                leading.fixedSize(horizontal: false, vertical: true)
                trailing.fixedSize(horizontal: false, vertical: true)
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                leading.fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                trailing.fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// One purchase as a row: merchant with the amount at the trailing edge, then
/// category · type, then when it happened. History shows only the time because
/// its day header carries the date; the Dashboard shows the date and time.
/// The row reads as one accessibility element.
struct PurchaseRow: View {
    enum DateStyle { case time, dateAndTime }

    let purchase: Purchase
    let dateStyle: DateStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AmountLine {
                Text(purchase.merchant).font(.headline)
            } trailing: {
                Text(Money.format(purchase.amountInCents)).fontWeight(.semibold).monospacedDigit()
            }
            Text("\(purchase.category.title) · \(purchase.spendingType.title)")
                .font(.subheadline).foregroundStyle(.secondary)
            Text(when).font(.caption).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var when: String {
        switch dateStyle {
        case .time: purchase.date.formatted(date: .omitted, time: .shortened)
        case .dateAndTime: purchase.date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}
