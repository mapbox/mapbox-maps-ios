import XCTest

final class ExamplesUITests: XCTestCase {

    override static func setUp() {
        // This is the setUp() class method.
        // XCTest calls it before calling the first test method.
        // Set up any overall initial state here.
        dismissEditHomeScreenAlert(timeout: 5)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_GrantLocationPermission() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to an example that should trigger location permissoon alert to be shown
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("User's Location")
        app.tables.firstMatch.cells.firstMatch.tap()

        acceptLocationPermissionAlert(timeout: 5)
    }

    func testEveryExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Tap every example cell in the table view, and then dismiss the example.
        for cell in app.tables.element(boundBy: 0).cells.allElementsBoundByIndex {
            // Open the example
            cell.tap()
            // Navigate back to the table view
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}

extension XCTestCase {
    /// Query SpringBoard for alerts and wait for `Allow` or `Allow While Using App` button
    func acceptLocationPermissionAlert(timeout: TimeInterval) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let predicate = NSPredicate(format: "%K IN %@", #keyPath(XCUIElementAttributes.label), [
            "Allow", // pre-iOS 13
            "Allow While Using App" // iOS13+
        ])
        let allowButton = springboard.alerts.firstMatch.buttons.matching(predicate).firstMatch

        XCTAssertTrue(allowButton.waitForExistence(timeout: timeout), "Can't find the allow button")

        allowButton.tap()
    }

    /// Query Springboard for "Edit Home Screen" alert to dismis it.
    static func dismissEditHomeScreenAlert(timeout: TimeInterval) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let editHomeScreenAlert = springboard.alerts["Edit Home Screen"]
        if editHomeScreenAlert.waitForExistence(timeout: timeout) {
            editHomeScreenAlert.buttons["Dismiss"].tap()
        }
    }
}
