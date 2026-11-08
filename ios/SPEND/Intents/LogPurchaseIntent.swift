import AppIntents

/// "Log a purchase": opens SPEND. to Quick Entry. Its only job is to leave a
/// request; the owner still types the purchase and taps Save. It never saves,
/// reads or summarizes purchases.
struct LogPurchaseIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a purchase"
    // iOS 17 to 25 read openAppWhenRun; iOS 26 and later read supportedModes.
    static let openAppWhenRun = true
    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground(.immediate) }

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickEntryRequest.shared.request()
        return .result()
    }
}
