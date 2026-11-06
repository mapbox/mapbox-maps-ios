import XCTest

/// Taps every example in the Search tab and checks the screen opens and the app keeps running.
/// XCTest, because UI tests cannot use Swift Testing yet.
final class OpenEveryExampleFromSearchUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        addUIInterruptionMonitor(withDescription: "Permission alert") { alert in
            let allow = alert.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Allow'")).firstMatch
            (allow.exists ? allow : alert.buttons.firstMatch).tap()
            return true
        }
        openSearchTab()
    }

    private func openSearchTab() {
        app.launch()
        app.tabBars.buttons["Search"].tap()
        XCTAssertTrue(app.cells.buttons.firstMatch.waitForExistence(timeout: 10), "Search tab shows no examples")
    }

    func testEveryExampleOpensFromSearchTab() {
        var opened = Set<String>()
        var unmovedScrolls = 0
        // Rows are virtualized, so walk the list screen by screen until scrolling no longer moves it.
        while unmovedScrolls < 3 {
            let rows = settledVisibleRows()
            if let row = rows.first(where: { !opened.contains($0) }) {
                opened.insert(row)
                open(app.cells.buttons.matching(identifier: row).firstMatch)
                continue
            }
            app.collectionViews.firstMatch.swipeUp(velocity: .slow)
            unmovedScrolls = settledVisibleRows() == rows ? unmovedScrolls + 1 : 0
        }
        XCTAssertGreaterThan(opened.count, 100, "Only \(opened.count) examples were opened")
        for catalog in ["UIKit", "SwiftUI", "Use Cases"] {
            XCTAssertTrue(opened.contains { $0.hasPrefix(catalog + "/") }, "No \(catalog) examples in Search")
        }
    }

    /// Identifiers ("<catalog>/<title>", set by `SearchView`) of the hittable rows once the list has stopped scrolling.
    private func settledVisibleRows() -> [String] {
        var rows = visibleRows
        for _ in 0..<20 {
            let again = visibleRows
            if again == rows { return rows }
            rows = again
        }
        XCTFail("The example list did not stop scrolling")
        return rows
    }

    private var visibleRows: [String] {
        app.cells.buttons.allElementsBoundByIndex.compactMap { $0.isHittable ? $0.identifier : nil }
    }

    private func open(_ row: XCUIElement) {
        let title = row.staticTexts.firstMatch.label
        row.tap()
        let opened = app.navigationBars[title].waitForExistence(timeout: 10)
        guard survived(title, "opening") else { return }
        XCTAssertTrue(opened, "\(title): did not open")
        app.navigationBars[title].buttons.firstMatch.tap()
        let returned = app.navigationBars["Search"].waitForExistence(timeout: 10)
        guard survived(title, "closing") else { return }
        XCTAssertTrue(returned, "\(title): did not return to Search")
    }

    /// Reports a crash and relaunches; the list starts from the top again and already opened rows are skipped.
    private func survived(_ title: String, _ step: String) -> Bool {
        if app.state == .runningForeground { return true }
        XCTFail("\(title): app crashed while \(step)")
        openSearchTab()
        return false
    }
}
