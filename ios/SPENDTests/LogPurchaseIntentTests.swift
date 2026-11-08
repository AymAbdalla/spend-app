import XCTest
import AppIntents
@testable import SPEND

@MainActor
final class LogPurchaseIntentTests: XCTestCase {
    func testRunningTheShortcutLeavesAQuickEntryRequest() async throws {
        let request = QuickEntryRequest.shared
        request.markHandled()
        defer { request.markHandled() }
        _ = try await LogPurchaseIntent().perform()
        XCTAssertTrue(request.isPending)
    }

    func testShortcutOpensTheApp() {
        XCTAssertTrue(LogPurchaseIntent.openAppWhenRun)
        if #available(iOS 26.0, *) {
            XCTAssertEqual(LogPurchaseIntent.supportedModes, .foreground(.immediate))
        }
    }
}
