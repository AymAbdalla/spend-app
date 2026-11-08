import XCTest

/// The Dashboard shows the purchase you just saved without scrolling, and its
/// sections come in the agreed order: tagline, "Purchase saved.", Today, This
/// week and This month, Recent purchases with See all, This month by category,
/// This month by intention, the USD footnote. Runs at the default text size on
/// iPhone 18 Pro, iPhone 17 Pro and the small phone.
final class DashboardLayoutUITests: XCTestCase {
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
        XCTAssertTrue(merchantField.isHittable)
        merchantField.tap()
        merchantField.typeText(merchant)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func row(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: "purchaseRow").firstMatch
    }

    /// No swipe happens before these checks: the row must already be on screen.
    private func assertFirstRowVisibleWithoutScrolling(_ app: XCUIApplication, _ mode: String) {
        let row = row(app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "\(mode): the saved purchase should be listed")
        let button = app.buttons["addPurchase"]
        XCTAssertTrue(row.isHittable, "\(mode): the first recent purchase must be tappable without scrolling")
        XCTAssertLessThanOrEqual(row.frame.maxY, button.frame.minY - 8,
                                 "\(mode): the whole row must end at least 8 points above the Add purchase button (row ends at \(row.frame.maxY), button starts at \(button.frame.minY))")
    }

    /// The agreed section order, top to bottom, read from the elements' positions.
    private func assertAgreedOrder(_ app: XCUIApplication, saved: Bool) {
        var named: [(String, XCUIElement)] = [("tagline", app.staticTexts["Feel every dollar."])]
        if saved { named.append(("Purchase saved.", app.staticTexts["saveConfirmation"])) }
        named += [("Today", app.staticTexts["todayTotal"]),
                  ("This week", app.staticTexts["weekTotal"]),
                  ("Recent purchases", app.staticTexts["Recent purchases"]),
                  ("first row", row(app)),
                  ("This month by category", app.staticTexts["This month by category"]),
                  ("This month by intention", app.staticTexts["This month by intention"]),
                  ("USD footnote", app.staticTexts["All amounts in USD. Stored on this device."])]
        for (name, element) in named { XCTAssertTrue(element.exists, "\(name) should be on the Dashboard") }
        for i in 1..<named.count {
            XCTAssertGreaterThan(named[i].1.frame.minY, named[i - 1].1.frame.minY,
                                 "\(named[i].0) should come after \(named[i - 1].0)")
        }
    }

    func testSavedPurchaseIsVisibleAboveTheAddBarInTheAgreedOrder() {
        let app = launch()
        enter(app)
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        assertFirstRowVisibleWithoutScrolling(app, "light")
        assertAgreedOrder(app, saved: true)
        attach(app, "Dashboard layout - light, just saved")
        app.terminate()
        app.launchArguments += ["-ui-appearance", "dark"]
        app.launch()
        XCTAssertTrue(app.staticTexts["todayTotal"].waitForExistence(timeout: 5))
        assertFirstRowVisibleWithoutScrolling(app, "dark")
        assertAgreedOrder(app, saved: false)
        attach(app, "Dashboard layout - dark after relaunch")
    }
}
