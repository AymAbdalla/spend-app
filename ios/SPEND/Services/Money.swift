import Foundation

enum Money {
    static func parse(_ text: String, locale: Locale = .current) throws -> Int64 {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.count <= 64 else { throw JournalError.invalidAmount }
        if let separator = locale.decimalSeparator, separator != "." {
            value = value.replacingOccurrences(of: separator, with: ".")
        }
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2,
              parts.allSatisfy({ $0.allSatisfy { ("0"..."9").contains($0) } }),
              !parts[0].isEmpty || (parts.count == 2 && !parts[1].isEmpty) else {
            throw JournalError.invalidAmount
        }
        let fraction = parts.count == 2 ? String(parts[1]) : ""
        guard parts.count == 1 || (1...2).contains(fraction.count),
              let whole = Int64(parts[0].isEmpty ? "0" : String(parts[0])) else {
            throw JournalError.invalidAmount
        }
        let (wholeCents, overflow) = whole.multipliedReportingOverflow(by: 100)
        let fractionalCents = Int64(fraction.padding(toLength: 2, withPad: "0", startingAt: 0)) ?? 0
        let (cents, additionOverflow) = wholeCents.addingReportingOverflow(fractionalCents)
        guard !overflow, !additionOverflow, cents > 0 else { throw JournalError.invalidAmount }
        return cents
    }

    static func format(_ cents: Int64, locale: Locale = .current) -> String {
        (Decimal(cents) / 100).formatted(.currency(code: "USD").locale(locale))
    }
}

enum JournalError: LocalizedError {
    case invalidAmount, merchantRequired, textTooLong, totalTooLarge, invalidRecord

    var errorDescription: String? {
        switch self {
        case .invalidAmount: "Enter a positive USD amount with up to two decimal places and no thousands separators."
        case .merchantRequired: "Add a merchant or a short description."
        case .textTooLong: "Keep the description within 200 characters and notes within 2,000 characters."
        case .totalTooLarge: "These purchases exceed the supported total. Your saved purchases are unchanged."
        case .invalidRecord: "A saved purchase could not be included. Your saved purchases are unchanged."
        }
    }
}
