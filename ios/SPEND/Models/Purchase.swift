import Foundation
import SwiftData

enum PurchaseCategory: String, CaseIterable, Identifiable {
    case foodAndDrink, groceries, transport, shopping, bills, health, entertainment, other

    var id: String { rawValue }
    var title: String {
        switch self {
        case .foodAndDrink: "Food & drink"
        case .groceries: "Groceries"
        case .transport: "Transport"
        case .shopping: "Shopping"
        case .bills: "Bills"
        case .health: "Health"
        case .entertainment: "Entertainment"
        case .other: "Other"
        }
    }
}

enum SpendingType: String, CaseIterable, Identifiable {
    case planned, impulse
    var id: String { rawValue }
    var title: String { self == .planned ? "Planned" : "Impulse" }
}

@Model
final class Purchase {
    @Attribute(.unique) var id: UUID
    var date: Date
    var merchant: String
    var amountInCents: Int64
    var categoryValue: String
    var spendingTypeValue: String
    var notes: String?

    init(id: UUID = UUID(), date: Date, merchant: String, amountInCents: Int64,
         category: PurchaseCategory, spendingType: SpendingType, notes: String? = nil) {
        self.id = id
        self.date = date
        self.merchant = merchant
        self.amountInCents = amountInCents
        self.categoryValue = category.rawValue
        self.spendingTypeValue = spendingType.rawValue
        self.notes = notes
    }

    var category: PurchaseCategory { PurchaseCategory(rawValue: categoryValue) ?? .other }
    var spendingType: SpendingType { SpendingType(rawValue: spendingTypeValue) ?? .planned }
    var record: SpendingRecord {
        SpendingRecord(date: date, amountInCents: amountInCents,
                       category: category, spendingType: spendingType)
    }
}

struct SpendingRecord {
    let date: Date
    let amountInCents: Int64
    let category: PurchaseCategory
    let spendingType: SpendingType
}
