import XCTest

class MapLoadingUITest: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()

        // Forward a detected AI coding-agent id (see
        // ../agent-detect.sh and ../run-uitests-with-agent-tag.sh, both in
        // the scripts/ directory) into the launched app's environment, for verifying
        // that outbound Mapbox requests carry an `agent/<id>` token in their
        // User-Agent header. The app does not automatically inherit this
        // test runner's environment, so it's copied explicitly; when the
        // variable isn't set (a normal run), nothing is added here and this
        // behaves exactly like a plain `launch()`. Test-tooling only - no
        // effect on the production app.
        if let agentId = ProcessInfo.processInfo.environment["MAPBOX_AGENT"],
            !agentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.launchEnvironment["MAPBOX_AGENT"] = agentId
        }
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
