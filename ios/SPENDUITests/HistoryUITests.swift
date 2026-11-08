import XCTest

/// History and the read-only purchase detail. The DEBUG-only argument
/// `-seed-history-fixture` saves four synthetic purchases on fixed calendar
/// dates into the test store, so headers and totals are the same in every time
/// zone and on any run date: Jan 15, 2026 ($4.50 + $32.10), Jan 14, 2026
/// ($2.75) and Jun 1, 2030 ($60.00).
final class HistoryUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-journal-test-store", UUID().uuidString,
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US"] + extra
        app.launch()
        return app
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func elements(_ app: XCUIApplication, _ identifier: String) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: identifier)
    }

    private func wait(for predicate: String, on element: Any, timeout: TimeInterval = 10) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: predicate), object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// iOS puts a narrow no-break space before AM and PM; compare on plain spaces.
    private func plain(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{202F}", with: " ").replacingOccurrences(of: "\u{00A0}", with: " ")
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

    /// Dashboard → See all, then wait for the History title.
    private func openHistory(_ app: XCUIApplication) {
        let seeAll = elements(app, "seeAllPurchases").firstMatch
        XCTAssertTrue(seeAll.waitForExistence(timeout: 5), "The Dashboard should offer See all")
        seeAll.tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5), "History should open")
    }

    private func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    /// Leave the app and come back, which fires the on-activate shortcut trigger.
    private func leaveAndReturn(_ app: XCUIApplication) {
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(wait(for: "state != \(XCUIApplication.State.runningForeground.rawValue)", on: app))
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    /// Three day sections, newest first, with the plan's totals and four rows.
    private func assertSeededSections(_ app: XCUIApplication) {
        XCTAssertTrue(elements(app, "historyList").firstMatch.waitForExistence(timeout: 5), "History should show its list")
        let keys = ["2030-06-01", "2026-01-15", "2026-01-14"]
        let headers = keys.map { app.staticTexts["daySection." + $0] }
        let totals = keys.map { app.staticTexts["dayTotal." + $0] }
        XCTAssertTrue(headers[0].waitForExistence(timeout: 5))
        XCTAssertEqual(headers.map(\.label), ["Sat, Jun 1, 2030", "Thu, Jan 15, 2026", "Wed, Jan 14, 2026"])
        XCTAssertEqual(totals.map(\.label), ["$60.00", "$36.60", "$2.75"])
        XCTAssertLessThan(headers[0].frame.minY, headers[1].frame.minY, "Newest day first")
        XCTAssertLessThan(headers[1].frame.minY, headers[2].frame.minY, "Newest day first")
        XCTAssertEqual(elements(app, "historyRow").count, 4)
    }

    func testSeededHistoryShowsDaySectionsDetailAndSurvivesRelaunch() {
        let app = launch(["-seed-history-fixture"])
        XCTAssertTrue(app.staticTexts["todayTotal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00", "Seeded purchases are never today")
        openHistory(app)
        assertSeededSections(app)
        let grocer = elements(app, "historyRow").matching(NSPredicate(format: "label CONTAINS 'Weekly grocer'")).firstMatch
        let bakery = elements(app, "historyRow").matching(NSPredicate(format: "label CONTAINS 'Corner bakery'")).firstMatch
        XCTAssertLessThan(grocer.frame.minY, bakery.frame.minY, "Newest purchase first within a day")
        XCTAssertTrue(grocer.label.contains("$32.10"))
        attach(app, "History - seeded light")
        grocer.tap()
        XCTAssertTrue(app.staticTexts["detailAmount"].waitForExistence(timeout: 5), "The detail should open")
        XCTAssertEqual(app.staticTexts["detailAmount"].label, "$32.10")
        XCTAssertEqual(app.staticTexts["detailMerchant"].label, "Weekly grocer")
        XCTAssertEqual(plain(app.staticTexts["detailDate"].label), "Jan 15, 2026 at 6:40 PM")
        XCTAssertEqual(app.staticTexts["detailCategory"].label, "Category, Groceries")
        XCTAssertEqual(app.staticTexts["detailType"].label, "Type, Planned")
        XCTAssertEqual(app.staticTexts["detailNotes"].label, "Weekly shop")
        attach(app, "Purchase detail - Weekly grocer")
        goBack(app)
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5), "Back should return to History")
        XCTAssertEqual(elements(app, "historyRow").count, 4)
        goBack(app)
        XCTAssertTrue(app.buttons["addPurchase"].waitForExistence(timeout: 5), "Back should return to the Dashboard")
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
        app.terminate()
        app.launchArguments.removeAll { $0 == "-seed-history-fixture" }
        app.launch()
        openHistory(app)
        assertSeededSections(app)
        attach(app, "History - after relaunch without the seed argument")
    }

    func testDashboardRowOpensDetailAndBackReturns() {
        let app = launch()
        enter(app)
        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        let row = elements(app, "purchaseRow").firstMatch
        for _ in 0..<3 {
            if row.frame.maxY <= app.buttons["addPurchase"].frame.minY - 8 { break }
            app.swipeUp()
        }
        XCTAssertTrue(row.isHittable)
        row.tap()
        XCTAssertTrue(app.staticTexts["detailAmount"].waitForExistence(timeout: 5), "A Dashboard row should open the detail")
        XCTAssertEqual(app.staticTexts["detailAmount"].label, "$12.34")
        XCTAssertEqual(app.staticTexts["detailMerchant"].label, "Test cafe")
        XCTAssertEqual(app.staticTexts["detailCategory"].label, "Category, Other")
        XCTAssertEqual(app.staticTexts["detailType"].label, "Type, Planned")
        XCTAssertFalse(app.staticTexts["detailNotes"].exists, "No Notes section without notes")
        attach(app, "Purchase detail - Test cafe")
        goBack(app)
        XCTAssertTrue(app.buttons["addPurchase"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$12.34")
    }

    func testEmptyHistoryShowsEmptyState() {
        let app = launch()
        openHistory(app)
        XCTAssertTrue(app.staticTexts["No purchases yet."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Purchases you save appear here, newest first."].exists)
        XCTAssertEqual(elements(app, "historyRow").count, 0)
        attach(app, "History - empty")
        goBack(app)
        XCTAssertTrue(app.buttons["addPurchase"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
    }

    func testShortcutFromHistoryReturnsToDashboardAndOpensQuickEntry() {
        let app = launch(["-run-log-purchase-on-activate", "-seed-history-fixture"])
        // The first activation already opens Quick Entry; close it to reach the Dashboard.
        XCTAssertTrue(app.textFields["amountField"].waitForExistence(timeout: 10))
        app.buttons["cancelEntry"].tap()
        XCTAssertTrue(wait(for: "isHittable == true", on: app.buttons["addPurchase"]))
        openHistory(app)
        XCTAssertTrue(elements(app, "historyList").firstMatch.waitForExistence(timeout: 5))
        leaveAndReturn(app)
        XCTAssertTrue(app.textFields["amountField"].waitForExistence(timeout: 10), "The shortcut should open Quick Entry from History")
        attach(app, "Shortcut from History - Quick Entry")
        app.buttons["cancelEntry"].tap()
        XCTAssertTrue(wait(for: "isHittable == true", on: app.buttons["addPurchase"]), "Quick Entry should close onto the Dashboard")
        XCTAssertFalse(app.navigationBars["History"].exists, "History should have been popped before Quick Entry opened")
        XCTAssertTrue(elements(app, "seeAllPurchases").firstMatch.exists)
        XCTAssertEqual(app.staticTexts["todayTotal"].label, "$0.00")
    }

    func testDarkAccessibilityHistoryRemainsReadable() {
        let app = launch(["-seed-history-fixture", "-ui-appearance", "dark",
                          "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        openHistory(app)
        XCTAssertTrue(app.staticTexts["daySection.2030-06-01"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["dayTotal.2030-06-01"].label, "$60.00")
        attach(app, "History - dark accessibility text")
        let busFare = elements(app, "historyRow").matching(NSPredicate(format: "label CONTAINS 'Bus fare'")).firstMatch
        for _ in 0..<8 {
            if busFare.exists && busFare.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(busFare.isHittable, "The last row must be reachable by scrolling at the largest text size")
        attach(app, "History - dark accessibility text scrolled")
        busFare.tap()
        XCTAssertTrue(app.staticTexts["detailAmount"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["detailAmount"].label, "$2.75")
        XCTAssertEqual(app.staticTexts["detailMerchant"].label, "Bus fare")
        attach(app, "Purchase detail - dark accessibility text")
    }
}
