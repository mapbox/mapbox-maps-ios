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
        let searchField = app.navigationBars.firstMatch.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Location")
        app.tables.firstMatch.cells.firstMatch.tap()

        // wait for the alert to appear
        sleep(2)

        // interact with the app so that UI interruption monitor gets triggered
        app.swipeUp()

        wait(for: [locationPermissionGrantedExpectation], timeout: 5)
    }
}
