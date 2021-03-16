import XCTest

class ExamplesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
