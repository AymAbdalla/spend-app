import SwiftUI

/// Every saved field of one purchase, read-only. Edit and delete are a later
/// slice, so nothing here changes the journal.
struct PurchaseDetailView: View {
    let purchase: Purchase

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Money.format(purchase.amountInCents))
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                        .accessibilityIdentifier("detailAmount")
                    Text(purchase.merchant)
                        .font(.title3.weight(.medium))
                        .accessibilityIdentifier("detailMerchant")
                    Text(purchase.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("detailDate")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                // The hero uses the card padding token; the List keeps its own shape.
                .listRowInsets(EdgeInsets(top: SpendDesign.cardPadding, leading: SpendDesign.cardPadding,
                                          bottom: SpendDesign.cardPadding, trailing: SpendDesign.cardPadding))
            }
            Section("Details") {
                LabeledContent("Category") {
                    Text(purchase.category.title).accessibilityIdentifier("detailCategory")
                }
                LabeledContent("Type") {
                    Text(purchase.spendingType.title).accessibilityIdentifier("detailType")
                }
            }
            if let notes = purchase.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes).accessibilityIdentifier("detailNotes")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Purchase")
        .navigationBarTitleDisplayMode(.inline)
    }
}
