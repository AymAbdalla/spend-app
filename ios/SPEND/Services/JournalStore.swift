import Foundation
import SwiftData

@MainActor
enum JournalStore {
    static func open(at url: URL) throws -> ModelContainer {
        let schema = Schema([Purchase.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = false
        return container
    }
}

struct PurchaseDraft {
    let id = UUID()
    var date = Date()
    var amount = ""
    var merchant = ""
    var category: PurchaseCategory = .other
    var spendingType: SpendingType = .planned
    var notes = ""
}

@MainActor
enum PurchaseWriter {
    static func save(_ draft: PurchaseDraft, in context: ModelContext,
                     locale: Locale = .current,
                     commit: (ModelContext) throws -> Void = { try $0.save() }) throws {
        let amount = try Money.parse(draft.amount, locale: locale)
        let merchant = draft.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !merchant.isEmpty else { throw JournalError.merchantRequired }
        guard merchant.count <= 200, notes.count <= 2_000 else { throw JournalError.textTooLong }
        let id = draft.id
        let existing = FetchDescriptor<Purchase>(predicate: #Predicate { $0.id == id })
        guard try context.fetchCount(existing) == 0 else { return }
        let purchase = Purchase(id: id, date: draft.date, merchant: merchant,
                                amountInCents: amount, category: draft.category,
                                spendingType: draft.spendingType, notes: notes.isEmpty ? nil : notes)
        context.insert(purchase)
        do {
            try commit(context)
        } catch {
            context.rollback()
            throw error
        }
    }
}
