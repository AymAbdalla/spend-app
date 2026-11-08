import XCTest

final class JournalUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-journal-test-store", UUID().uuidString,
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US"] + extra
        app.launch()
        return app
    }

    private func enter(_ app: XCUIApplication, amount: String = "12.34", merchant: String = "Test cafe") {
        let add = app.buttons["addPurchase"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()
        let amountField = app.textFields["amountField"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 3))
        amountField.tap()
        amountField.typeText(amount)
        app.buttons["keyboardDone"].tap()
        let merchantField = app.textFields["merchantField"]
        for _ in 0..<5 {
            if merchantField.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(merchantField.isHittable, "Merchant must be reachable by scrolling at every text size")
        merchantField.tap()
        merchantField.typeText(merchant)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testSavePersistsAcrossRelaunchAndRepeatedTaps() {
        let app = launch()
        enter(app)
        attach(app, "Quick Entry - light")
        app.buttons["savePurchase"].doubleTap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["weekTotal"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["monthTotal"].label, "$12.34")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "purchaseRow").count, 1)
        attach(app, "Dashboard - saved purchase")
        app.terminate()
        app.launchArguments += ["-ui-appearance", "dark"]
        app.launch()
        XCTAssertTrue(app.staticTexts["todayTotal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["weekTotal"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["monthTotal"].label, "$12.34")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "purchaseRow").count, 1)
        let row = app.descendants(matching: .any).matching(identifier: "purchaseRow").firstMatch
        XCTAssertTrue(row.label.contains("Test cafe"))
        XCTAssertTrue(row.label.contains("$12.34"))
        attach(app, "Dashboard - dark after relaunch")
        for _ in 0..<3 {
            if row.frame.maxY <= app.buttons["addPurchase"].frame.minY - 8 { break }
            app.swipeUp()
        }
        XCTAssertTrue(row.isHittable)
        XCTAssertLessThanOrEqual(row.frame.maxY, app.buttons["addPurchase"].frame.minY - 8,
                                 "The entire row must be above the Add purchase bar")
        attach(app, "Dashboard - dark recent purchase")
        app.terminate()
        app.launchArguments.append("-fail-initial-load")
        app.launch()
        XCTAssertTrue(app.buttons["retryStore"].waitForExistence(timeout: 5))
        app.buttons["retryStore"].tap()
        XCTAssertTrue(app.staticTexts["todayTotal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
    }

    func testCancelAndInvalidEntryDoNotCreatePurchases() {
        let app = launch()
        enter(app, merchant: "Canceled purchase")
        app.buttons["cancelEntry"].tap()
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "purchaseRow").count, 0)
        enter(app, amount: "0", merchant: "Invalid purchase")
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["entryError"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.textFields["amountField"].exists)
        app.buttons["cancelEntry"].tap()
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
    }

    func testFailedSaveRetainsFieldsAndRetrySucceeds() {
        let app = launch(["-fail-next-save"])
        enter(app)
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["entryError"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["amountField"].value as? String, "12.34")
        XCTAssertEqual(app.textFields["merchantField"].value as? String, "Test cafe")
        attach(app, "Quick Entry - storage error")
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "purchaseRow").count, 1)
    }

    func testCategoryAndImpulseAppearInMonthlySummary() {
        let app = launch()
        enter(app)
        app.buttons["keyboardDone"].tap()
        app.buttons["categoryPicker"].tap()
        app.buttons["Food & drink"].tap()
        app.buttons["spendingTypePicker"].tap()
        app.buttons["Impulse"].tap()
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["categoryTotal.foodAndDrink"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["categoryTotal.foodAndDrink"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["typeTotal.impulse"].label, "$12.34")
    }

    func testDarkLargeTextEntryRemainsUsable() {
        let app = launch(["-ui-appearance", "dark", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        attach(app, "Dashboard - dark accessibility text")
        enter(app, merchant: "Large text purchase")
        attach(app, "Quick Entry - dark accessibility text")
        XCTAssertTrue(app.buttons["savePurchase"].isHittable)
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
        attach(app, "Dashboard - dark accessibility text saved")
    }
}
