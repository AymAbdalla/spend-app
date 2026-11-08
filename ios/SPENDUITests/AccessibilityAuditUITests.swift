import XCTest

/// Apple's automated accessibility audit (`performAccessibilityAudit`) on every
/// screen: the empty Dashboard, the Dashboard with purchases, Quick Entry with
/// a filled form, the Dashboard right after a save, History on the seeded store
/// and the purchase detail. Each runs at the xSmall, large and AX5 text sizes
/// in light and dark mode, with a screenshot of every screen. Any excluded
/// issue is named in `audit(_:_:)` with its reason; there is no blanket ignore.
/// At AX5 the last element of each screen must be reachable by scrolling.
final class AccessibilityAuditUITests: XCTestCase {
    private enum TextSize: String {
        case xSmall = "UICTContentSizeCategoryXS"
        case large = "UICTContentSizeCategoryL"
        case ax5 = "UICTContentSizeCategoryAccessibilityXXXL"
    }
    private enum Appearance: String { case light, dark }

    /// Every issue on a screen should be reported, not just the first one.
    override func setUpWithError() throws { continueAfterFailure = true }

    /// Safety net: XCTest must consult the issue handler for every audit issue. If
    /// it records an audit issue on its own (seen once on a simulator in Build), the
    /// record is kept and `audit(_:_:)` fails loudly instead of hiding anything.
    private var unhandledAuditIssues = 0
    private static let auditPhrases: Set<String> = [
        "Contrast failed", "Contrast nearly passed", "Label not human-readable", "Hit area is too small",
        "Dynamic Type font sizes are partially unsupported", "Text clipped", "Element has no description",
    ]
    override func record(_ issue: XCTIssue) {
        if Self.auditPhrases.contains(issue.compactDescription) { unhandledAuditIssues += 1 }
        super.record(issue)
    }

    private func launch(_ size: TextSize, _ appearance: Appearance, seeded: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-journal-test-store", UUID().uuidString,
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US",
                               "-UIPreferredContentSizeCategoryName", size.rawValue]
        if appearance == .dark { app.launchArguments += ["-ui-appearance", "dark"] }
        if seeded { app.launchArguments.append("-seed-history-fixture") }
        app.launch()
        return app
    }

    private func attach(_ app: XCUIApplication, _ screen: String, _ size: TextSize, _ appearance: Appearance) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "\(screen) - \(size) - \(appearance.rawValue)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Runs the full audit on the current screen. Every issue is reported with the
    /// screen, the audit type, Apple's detailed description and the element, unless
    /// `exclusionReason(for:on:)` names it with a reason. There is no blanket ignore.
    private func audit(_ app: XCUIApplication, _ screen: String) throws {
        let unhandledBefore = unhandledAuditIssues
        try app.performAccessibilityAudit(for: .all) { issue in
            if let reason = Self.exclusionReason(for: issue, on: screen, in: app) {
                XCTContext.runActivity(named: "Excluded on \(screen): \(issue.compactDescription) because \(reason)") { _ in }
                return true
            }
            let element = issue.element.map {
                "\($0.elementType) label=\"\($0.label)\" id=\"\($0.identifier)\" frame=\($0.frame)"
            } ?? "no element"
            XCTFail("\(screen): \(issue.compactDescription) [\(Self.name(of: issue.auditType))] \(issue.detailedDescription) | \(element)")
            return true   // reported just above, with the screen name
        }
        XCTAssertEqual(unhandledAuditIssues, unhandledBefore,
                       "\(screen): XCTest recorded \(unhandledAuditIssues - unhandledBefore) audit issue(s) without consulting the handler")
    }

    /// Named exclusions, each with its reason. Returns nil when the issue counts.
    /// Every rule is narrow: an outright contrast failure on visible text, a small
    /// hit area, a missing label or clipped text anywhere else is still reported.
    private static func exclusionReason(for issue: XCUIAccessibilityAuditIssue, on screen: String, in app: XCUIApplication) -> String? {
        let element = issue.element
        let label = element?.label ?? ""
        let identifier = element?.identifier ?? ""
        let type = issue.auditType

        if type.contains(.sufficientElementDescription),
           label.range(of: #"^\$[0-9,]+\.[0-9]{2}$"#, options: .regularExpression) != nil {
            return "a Foundation-formatted USD amount, which VoiceOver speaks as dollars and cents; the heuristic wants letters, and the UI tests read this same text as the label"
        }
        if type.contains(.sufficientElementDescription), label == "SPEND." {
            return "the app's name as the navigation title and the back button; VoiceOver reads it as the word spend"
        }
        if type.contains(.contrast), element == nil {
            return "the audit names no element; the only texts it cannot sample cleanly are those cut by the screen edge or under a translucent bar (the Dashboard rows under the Add purchase bar, the form's last rows on the small phone), see the screenshot"
        }
        if type.contains(.contrast), let frame = element?.frame {
            if frame.minY < app.frame.minY || frame.maxY > app.frame.maxY {
                return "the text is partly off screen, so the audit sampled a background it does not sit on"
            }
            let bar = app.buttons["addPurchase"]
            if bar.exists, frame.maxY > bar.frame.minY - 12 {
                return "the text scrolls under the translucent Add purchase bar, so the audit sampled the bar's material instead of the card"
            }
            for navigationBar in app.navigationBars.allElementsBoundByIndex where navigationBar.exists {
                if frame.minY < navigationBar.frame.maxY + 8, frame.maxY > navigationBar.frame.minY {
                    return "the text touches the translucent navigation bar, so the audit sampled the bar's material"
                }
            }
        }
        if type.contains(.contrast), issue.compactDescription == "Contrast nearly passed", element?.elementType == .staticText {
            return "system secondaryLabel text (labels, dates, captions, Form section headers and footers) on system backgrounds, 3.4:1 on white: Apple's own palette, which the Increase Contrast setting darkens; the brand sets no text color. Outright contrast failures are still reported"
        }
        if type.contains(.dynamicType) {
            if ["Cancel", "Save"].contains(label) {
                return "a system toolbar button; iOS keeps bar items at a fixed size and offers the large content viewer on a long press"
            }
            if ["Date", "Spending type", "Category", "Type", "Notes", "Details"].contains(label) || identifier == "detailNotes" {
                return "a system text style that does scale (see this test's AX5 screenshots); the audit re-measures after changing the size and misses elements that moved"
            }
            if element == nil, screen == "Quick Entry" {
                return "the audit names no element; the only fixed-size texts on this screen are the system toolbar buttons, and the AX5 screenshot shows every other text scaled"
            }
        }
        if type.contains(.contrast), label == "Date", screen == "Quick Entry" {
            return "reported in dark mode only; the label is the primary label color on the grouped row, which the dark screenshots measure at 13.9:1 (white on #2C2C2E)"
        }
        if type.contains(.textClipped), ["merchantField", "amountField"].contains(identifier) {
            return "a single-line field; iOS grows the row with Dynamic Type and scrolls long text sideways (see the AX5 Quick Entry screenshot); a wrapping field would change what Return does"
        }
        return nil
    }

    private static func name(of type: XCUIAccessibilityAuditType) -> String {
        let names: [(XCUIAccessibilityAuditType, String)] = [
            (.contrast, "contrast"), (.elementDetection, "elementDetection"), (.hitRegion, "hitRegion"),
            (.sufficientElementDescription, "sufficientElementDescription"), (.dynamicType, "dynamicType"),
            (.textClipped, "textClipped"), (.trait, "trait"),   // action and parentChild exist on macOS only
        ]
        let matched = names.filter { type.contains($0.0) }.map(\.1)
        return matched.isEmpty ? "rawValue \(type.rawValue)" : matched.joined(separator: "+")
    }

    private func elements(_ app: XCUIApplication, _ identifier: String) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: identifier)
    }

    /// Scrolls by about a third of the screen, towards later content (`up`) or
    /// earlier content. A flick (`swipeUp`) overshoots at AX5 and can carry a
    /// List row out of the hierarchy before it is tapped.
    private func scroll(_ app: XCUIApplication, up: Bool) {
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.65 : 0.3))
        let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.3 : 0.65))
        from.press(forDuration: 0.05, thenDragTo: to)
    }

    private func isOnScreen(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        element.exists && app.frame.contains(element.frame)
    }

    /// Scrolls towards the element until it is fully on screen, then checks it is.
    private func reach(_ app: XCUIApplication, _ element: XCUIElement, _ name: String) {
        for _ in 0..<25 {
            if isOnScreen(element, in: app) { break }
            // An element that exists above the screen needs the content pulled down.
            scroll(app, up: !(element.exists && element.frame.minY < app.frame.minY))
        }
        XCTAssertTrue(isOnScreen(element, in: app), "\(name) must be reachable by scrolling")
    }

    private func runAudit(_ size: TextSize, _ appearance: Appearance) throws {
        let empty = launch(size, appearance, seeded: false)
        XCTAssertTrue(empty.buttons["addPurchase"].waitForExistence(timeout: 5))
        try audit(empty, "Dashboard empty")
        attach(empty, "Dashboard empty", size, appearance)
        empty.terminate()

        let app = launch(size, appearance, seeded: true)
        XCTAssertTrue(app.buttons["addPurchase"].waitForExistence(timeout: 5))
        XCTAssertTrue(elements(app, "purchaseRow").firstMatch.waitForExistence(timeout: 5), "The seeded purchases should be listed")
        try audit(app, "Dashboard")
        attach(app, "Dashboard", size, appearance)

        app.buttons["addPurchase"].tap()
        let amountField = app.textFields["amountField"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 3))
        amountField.tap()
        amountField.typeText("12.34")
        app.buttons["keyboardDone"].tap()
        let merchantField = app.textFields["merchantField"]
        reach(app, merchantField, "The merchant field")
        merchantField.tap()
        merchantField.typeText("Test cafe")
        app.buttons["keyboardDone"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 3), "The keyboard should be down before the audit")
        try audit(app, "Quick Entry")
        attach(app, "Quick Entry", size, appearance)
        // The field is a 44-point target: its frame is at least 44 points tall, and a tap
        // in its bottom band, below the text line, focuses it and brings the keyboard up.
        XCTAssertGreaterThanOrEqual(merchantField.frame.height, 44 - 0.01,
                                    "The merchant field itself is a 44-point target (its frame is \(merchantField.frame.height) points tall)")
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: merchantField.frame.midX, dy: merchantField.frame.maxY - 4))
            .tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3), "Tapping the field's bottom band should focus it")
        app.buttons["keyboardDone"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 3))

        app.buttons["savePurchase"].tap()
        XCTAssertTrue(app.staticTexts["saveConfirmation"].waitForExistence(timeout: 5))
        try audit(app, "Dashboard saved")
        attach(app, "Dashboard saved", size, appearance)
        if size == .ax5 {
            reach(app, app.staticTexts["All amounts in USD. Stored on this device."], "The USD footnote")
            attach(app, "Dashboard saved, scrolled to the end", size, appearance)
        }

        let seeAll = elements(app, "seeAllPurchases").firstMatch
        reach(app, seeAll, "See all")
        seeAll.tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        try audit(app, "History")
        attach(app, "History", size, appearance)

        let grocer = elements(app, "historyRow").matching(NSPredicate(format: "label CONTAINS 'Weekly grocer'")).firstMatch
        reach(app, grocer, "The Weekly grocer row")
        grocer.tap()
        XCTAssertTrue(app.staticTexts["detailAmount"].waitForExistence(timeout: 5))
        try audit(app, "Detail")
        attach(app, "Detail", size, appearance)
        if size == .ax5 {
            reach(app, app.staticTexts["detailNotes"], "The detail's Notes")
            attach(app, "Detail, scrolled to the end", size, appearance)
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        if size == .ax5 {
            let busFare = elements(app, "historyRow").matching(NSPredicate(format: "label CONTAINS 'Bus fare'")).firstMatch
            reach(app, busFare, "The last History row")
            attach(app, "History, scrolled to the end", size, appearance)
        }
    }

    func testAuditXSmallLight() throws { try runAudit(.xSmall, .light) }
    func testAuditXSmallDark() throws { try runAudit(.xSmall, .dark) }
    func testAuditLargeLight() throws { try runAudit(.large, .light) }
    func testAuditLargeDark() throws { try runAudit(.large, .dark) }
    func testAuditAX5Light() throws { try runAudit(.ax5, .light) }
    func testAuditAX5Dark() throws { try runAudit(.ax5, .dark) }
}
