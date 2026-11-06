import SwiftUI
import SwiftData
import Combine

struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var typeSize
    @Query(sort: \Purchase.date, order: .reverse) private var purchases: [Purchase]
    @State private var showingEntry = false
    @State private var saved = false
    @State private var now = Date()
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    let commit: (ModelContext) throws -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Feel every dollar.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if saved {
                        Label("Purchase saved.", systemImage: "checkmark.circle")
                            .accessibilityIdentifier("saveConfirmation")
                    }
                    summaryContent
                    recentPurchases
                    Text("All amounts in USD. Stored on this device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("SPEND.")
            .safeAreaInset(edge: .bottom) {
                Button {
                    saved = false
                    showingEntry = true
                } label: {
                    Label("Add purchase", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("addPurchase")
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
            }
            .sheet(isPresented: $showingEntry, onDismiss: {
                if saved { AccessibilityNotification.Announcement("Purchase saved").post() }
            }) {
                QuickEntryView(commit: commit) {
                    now = Date()
                    saved = true
                }
            }
        }
        .onReceive(clock) { now = $0 }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in now = Date() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { now = Date() } }
    }

    @ViewBuilder private var summaryContent: some View {
        switch Result(catching: { try SpendingSummary.calculate(purchases.map(\.record), now: now, calendar: .autoupdatingCurrent) }) {
        case .success(let summary):
            VStack(alignment: .leading, spacing: 8) {
                Text("Today").font(.headline).foregroundStyle(.secondary)
                Text(Money.format(summary.today))
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .accessibilityIdentifier("todayTotal")
                Text(now.formatted(date: .complete, time: .omitted))
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            VStack(spacing: 16) {
                totalRow("This week", amount: summary.week, identifier: "weekTotal")
                Divider()
                totalRow("This month", amount: summary.month, identifier: "monthTotal")
            }
            .padding(20)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 16) {
                Text("This month by category").font(.headline)
                if summary.categories.isEmpty {
                    Text("Categories will appear as you log purchases.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(PurchaseCategory.allCases.filter { summary.categories[$0] != nil }) { category in
                        totalRow(category.title, amount: summary.categories[category, default: 0],
                                 identifier: "categoryTotal." + category.rawValue)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("This month by intention").font(.headline)
                ForEach(SpendingType.allCases) { type in
                    totalRow(type.title, amount: summary.types[type, default: 0], identifier: "typeTotal." + type.rawValue)
                }
            }
        case .failure(let error):
            Label(error.localizedDescription, systemImage: "exclamationmark.circle")
        }
    }

    private func totalRow(_ title: String, amount: Int64, identifier: String) -> some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                                                : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        return layout {
            Text(title).foregroundStyle(.secondary)
            if !typeSize.isAccessibilitySize { Spacer(minLength: 8) }
            Text(Money.format(amount)).fontWeight(.semibold).monospacedDigit()
                .accessibilityIdentifier(identifier)
        }
    }

    private var recentPurchases: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent purchases").font(.headline)
            if purchases.isEmpty {
                Text("Start with one purchase.").font(.title3.weight(.medium))
                Text("Record what you spent, then see where it goes.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(purchases.prefix(5))) { purchase in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(purchase.merchant).font(.headline)
                        Text(Money.format(purchase.amountInCents)).monospacedDigit()
                        Text("\(purchase.category.title) · \(purchase.spendingType.title)")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text(purchase.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("purchaseRow")
                }
            }
        }
    }
}
