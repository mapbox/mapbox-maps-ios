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
        app.launchForwardingAgentTag()

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
        app.launchForwardingAgentTag()

        // Tap every example cell in the table view, and then dismiss the example.
        for cell in app.tables.element(boundBy: 0).cells.allElementsBoundByIndex {
            // Open the example
            cell.tap()
            // Navigate back to the table view
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}

extension XCUIApplication {
    /// Name of the environment variable that, when present in this process's
    /// (the XCUITest runner's) own environment, identifies the AI coding
    /// agent (if any) driving the host machine that invoked `xcodebuild
    /// test` - see `scripts/agent-detect.sh` and
    /// `scripts/run-uitests-with-agent-tag.sh`.
    private static let agentTagEnvKey = "MAPBOX_AGENT"

    /// Launches the app, forwarding a detected AI coding-agent id (if any)
    /// into its `launchEnvironment` so outbound Mapbox requests made during
    /// this run can be verified to carry an `agent/<id>` token in their
    /// User-Agent header.
    ///
    /// The app under test does not automatically inherit this test runner's
    /// environment, so the value has to be copied into `launchEnvironment`
    /// explicitly. When the variable isn't present (a normal run, not
    /// launched via `run-uitests-with-agent-tag.sh`), nothing is added and
    /// this behaves exactly like a plain `launch()`.
    ///
    /// This is test-tooling only, used to verify an upcoming Common SDK
    /// User-Agent change; it has no effect on the production app.
    func launchForwardingAgentTag() {
        if let agentId = ProcessInfo.processInfo.environment[Self.agentTagEnvKey],
            !agentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            launchEnvironment[Self.agentTagEnvKey] = agentId
        }
        launch()
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
