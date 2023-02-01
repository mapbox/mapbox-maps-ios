import XCTest

class MapLoadingUITest: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        let existancePredicate = NSPredicate(format: "exists == 1")
        let query = app.alerts.firstMatch
        expectation(for: existancePredicate, evaluatedWith: query, handler: nil)

        waitForExpectations(timeout: 10, handler: nil)

        let loadedPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Loaded")
        let loadedAlert = app.alerts.containing(loadedPredicate)

        XCTAssertEqual(loadedAlert.count, 1)

        let failedPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Failed")
        let failedAlert = app.alerts.containing(failedPredicate)

        XCTAssertEqual(failedAlert.count, 0)
    }

}
