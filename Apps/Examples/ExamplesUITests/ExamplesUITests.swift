import XCTest

final class ExamplesUITests: XCTestCase {
    private var locationAuthorizationAlertMonitor: NSObjectProtocol?

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

        let locationPermissionGrantedExpectation = expectation(description: "Location permission granted")
        locationAuthorizationAlertMonitor = addUIInterruptionMonitor(withDescription: "", handler: { alert in
            let allowButton = alert.buttons["Allow While Using App"]

            guard allowButton.exists else {
                XCTFail("Can't find the allow button")
                return false
            }
            locationPermissionGrantedExpectation.fulfill()
            allowButton.tap()
            return true
        })

        // Navigate to an example that should trigger location permissoon alert to be shown
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Location")
        app.tables.firstMatch.cells.firstMatch.tap()

        // pre iOS 13 solution
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let allowBtn = springboard.buttons["Allow"]

        // Wait for iOS 12 popup. On iOS 13+ we also need that
        // to leave some room for monitor to catch alert
        if allowBtn.waitForExistence(timeout: 2) {
            allowBtn.tap()
            locationPermissionGrantedExpectation.fulfill()
        }

        // interact with the app so that UI interruption monitor gets triggered
        app.swipeUp()

        wait(for: [locationPermissionGrantedExpectation], timeout: 5)
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
