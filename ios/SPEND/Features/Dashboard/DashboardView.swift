import SwiftUI
import SwiftData
import Combine

/// Sections, top to bottom: tagline; "Purchase saved." when shown; Today;
/// This week and This month; Recent purchases with See all; This month by
/// category; This month by intention; the USD footnote. Every section is a
/// `SpendCard`, so the purchase you just saved shows without scrolling.
struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var typeSize
    @Query(sort: \Purchase.date, order: .reverse) private var purchases: [Purchase]
    @State private var showingEntry = false
    @State private var saved = false
    @State private var path = NavigationPath()
    @State private var now = Date()
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    let commit: (ModelContext) throws -> Void
    let entryRequest: QuickEntryRequest

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendDesign.sectionGap) {
                    Text("Feel every dollar.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if saved {
                        Label("Purchase saved.", systemImage: "checkmark.circle")
                            .accessibilityIdentifier("saveConfirmation")
                    }
                    summaryContent
                    Text("All amounts in USD. Stored on this device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(SpendDesign.pageMargin)
            }
            .background(SpendDesign.pageBackground)
            .navigationTitle("SPEND.")
            .navigationDestination(for: HistoryDestination.self) { _ in HistoryView() }
            .navigationDestination(for: Purchase.self) { PurchaseDetailView(purchase: $0) }
            .safeAreaInset(edge: .bottom) {
                Button {
                    openEntry()
                } label: {
                    Label("Add purchase", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("addPurchase")
                .padding(.horizontal, SpendDesign.pageMargin)
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
        // initial: true also honors a request made before this screen existed.
        .onChange(of: entryRequest.isPending, initial: true) { _, isPending in
            if isPending { openEntryForShortcut() }
        }
    }

    /// Clears the old "Purchase saved." first, so a later Cancel can't announce it.
    private func openEntry() {
        saved = false
        showingEntry = true
    }

    /// The "Log a purchase" shortcut opens Quick Entry like Add purchase. It first
    /// pops History or a detail, so "Purchase saved." lands on the Dashboard. If
    /// the sheet is already open, it stays as it is, which keeps a typed draft.
    private func openEntryForShortcut() {
        entryRequest.markHandled()
        path = NavigationPath()
        if !showingEntry { openEntry() }
    }

    /// The totals in the agreed order, with the recent purchases third. If the
    /// totals can't be calculated, the message replaces them and the recent
    /// purchases still show.
    @ViewBuilder private var summaryContent: some View {
        switch Result(catching: { try SpendingSummary.calculate(purchases.map(\.record), now: now, calendar: .autoupdatingCurrent) }) {
        case .success(let summary):
            todayCard(summary)
            periodCard(summary)
            recentPurchases
            categoryCard(summary)
            intentionCard(summary)
        case .failure(let error):
            Label(error.localizedDescription, systemImage: "exclamationmark.circle")
            recentPurchases
        }
    }

    private func todayCard(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today").font(.headline).foregroundStyle(.secondary)
            Text(Money.format(summary.today))
                .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .accessibilityIdentifier("todayTotal")
            Text(now.formatted(date: .complete, time: .omitted))
                .font(.footnote).foregroundStyle(.secondary)
        }
        .spendCard()
    }

    private func periodCard(_ summary: SpendingSummary) -> some View {
        VStack(spacing: SpendDesign.rowGap) {
            totalRow("This week", amount: summary.week, identifier: "weekTotal")
            Divider()
            totalRow("This month", amount: summary.month, identifier: "monthTotal")
        }
        .spendCard()
    }

    private func categoryCard(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: SpendDesign.rowGap) {
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
        .spendCard()
    }

    private func intentionCard(_ summary: SpendingSummary) -> some View {
        VStack(alignment: .leading, spacing: SpendDesign.rowGap) {
            Text("This month by intention").font(.headline)
            ForEach(SpendingType.allCases) { type in
                totalRow(type.title, amount: summary.types[type, default: 0], identifier: "typeTotal." + type.rawValue)
            }
        }
        .spendCard()
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

    /// The five newest purchases in one card, separated by dividers. Each row
    /// opens its detail, so it ends in a chevron; See all opens History.
    private var recentPurchases: some View {
        let recent = Array(purchases.prefix(5))
        return VStack(alignment: .leading, spacing: SpendDesign.rowGap) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent purchases").font(.headline)
                Spacer(minLength: 8)
                // The label is small text, so the link itself is given a 44-point hit area.
                NavigationLink(value: HistoryDestination()) {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                        .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .accessibilityIdentifier("seeAllPurchases")
            }
            if recent.isEmpty {
                Text("Start with one purchase.").font(.title3.weight(.medium))
                Text("Record what you spent, then see where it goes.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recent) { purchase in
                    if purchase != recent.first { Divider() }
                    NavigationLink(value: purchase) {
                        HStack(spacing: 12) {
                            PurchaseRow(purchase: purchase, dateStyle: .dateAndTime)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("purchaseRow")
                }
            }
        }
        .spendCard()
    }
}
