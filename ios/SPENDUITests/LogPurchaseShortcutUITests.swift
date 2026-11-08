import XCTest

/// The "Log a purchase" shortcut with a simulated trigger: DEBUG launch arguments
/// make the app run the real intent itself, because the Simulator can't press the
/// Action Button for a shortcut. The iPhone checklist covers the button.
final class LogPurchaseShortcutUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(_ extra: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-journal-test-store", UUID().uuidString,
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US"] + extra
        app.launch()
        return app
    }

    /// Quick Entry is open and the amount field has focus: the Done control only
    /// shows while a field is focused, and nothing here has tapped a field.
    private func waitForQuickEntry(_ app: XCUIApplication) {
        XCTAssertTrue(app.textFields["amountField"].waitForExistence(timeout: 10), "Quick Entry should open")
        XCTAssertTrue(app.buttons["keyboardDone"].waitForExistence(timeout: 3), "The amount field should be focused")
    }

    private func typeMerchant(_ app: XCUIApplication, _ merchant: String) {
        app.buttons["keyboardDone"].tap()
        let merchantField = app.textFields["merchantField"]
        for _ in 0..<5 {
            if merchantField.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(merchantField.isHittable)
        merchantField.tap()
        merchantField.typeText(merchant)
    }

    private func wait(for predicate: String, on element: Any, timeout: TimeInterval = 10) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: predicate), object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Leave the app and come back, which fires the on-activate trigger again.
    private func leaveAndReturn(_ app: XCUIApplication) {
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(wait(for: "state != \(XCUIApplication.State.runningForeground.rawValue)", on: app))
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    /// Wait until the sheet has gone and the Dashboard can be used again.
    private func waitForDashboard(_ app: XCUIApplication) {
        XCTAssertTrue(wait(for: "isHittable == true", on: app.buttons["addPurchase"]), "Dashboard should be usable")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func rows(_ app: XCUIApplication) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "purchaseRow")
    }

    func testShortcutAtLaunchOpensQuickEntryAndSaves() {
        let app = launch(["-run-log-purchase-at-launch"])
        waitForQuickEntry(app)
        attach(app, "Shortcut - Quick Entry at launch")
        // No tap first: typing only works because the amount field already has focus.
        app.textFields["amountField"].typeText("12.34")
        typeMerchant(app, "Test cafe")
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        XCTAssertEqual(rows(app).count, 1)
        XCTAssertTrue(rows(app).firstMatch.label.contains("Test cafe"))
        attach(app, "Shortcut - Dashboard after save")
    }

    func testShortcutWaitsForJournalRetryThenOpensQuickEntry() {
        let app = launch(["-fail-initial-load", "-run-log-purchase-at-launch"])
        XCTAssertTrue(app.buttons["retryStore"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.textFields["amountField"].exists)
        attach(app, "Shortcut - journal retry screen")
        app.buttons["retryStore"].tap()
        waitForQuickEntry(app)
        app.buttons["cancelEntry"].tap()
        waitForDashboard(app)
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
    }

    func testCancelAfterShortcutSavesNothing() {
        let app = launch(["-run-log-purchase-at-launch"])
        waitForQuickEntry(app)
        app.textFields["amountField"].typeText("12.34")
        app.buttons["cancelEntry"].tap()
        waitForDashboard(app)
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
        XCTAssertEqual(rows(app).count, 0)
        XCTAssertFalse(app.staticTexts["saveConfirmation"].exists)
    }

    func testShortcutAgainKeepsTypedDraft() {
        let app = launch(["-run-log-purchase-on-activate"])
        waitForQuickEntry(app)
        app.textFields["amountField"].typeText("8.75")
        leaveAndReturn(app)
        // Give the second request time to be handled before checking the sheet.
        _ = wait(for: "exists == false", on: app.textFields["amountField"], timeout: 2)
        XCTAssertTrue(app.textFields["amountField"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["amountField"].value as? String, "8.75")
        XCTAssertEqual(app.textFields.matching(identifier: "amountField").count, 1)
        attach(app, "Shortcut - draft kept after second run")
        app.buttons["cancelEntry"].tap()
        waitForDashboard(app)
        XCTAssertEqual(rows(app).count, 0)
    }

    func testShortcutAfterSaveClearsOldConfirmation() {
        let app = launch(["-run-log-purchase-on-activate"])
        waitForQuickEntry(app)
        app.textFields["amountField"].typeText("12.34")
        typeMerchant(app, "Test cafe")
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        leaveAndReturn(app)
        waitForQuickEntry(app)
        XCTAssertFalse(app.staticTexts["saveConfirmation"].exists)
        app.buttons["cancelEntry"].tap()
        waitForDashboard(app)
        XCTAssertFalse(app.staticTexts["saveConfirmation"].exists, "Cancel must not bring back the old confirmation")
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        XCTAssertEqual(rows(app).count, 1)
    }
}
