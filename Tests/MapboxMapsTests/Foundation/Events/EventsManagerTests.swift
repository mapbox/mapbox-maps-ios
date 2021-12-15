import XCTest
@testable import MapboxMaps

final class EventsManagerTests: XCTestCase {

    var eventsManager: EventsManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        eventsManager = try EventsManager.shared(withAccessToken: mapboxAccessToken())
    }

    override func tearDown() {
        eventsManager = nil
        super.tearDown()
    }

    func testUserDefaultsDynamicProperty() {
        UserDefaults.standard.MGLMapboxMetricsEnabled = false

        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "MGLMapboxMetricsEnabled"), true)

        UserDefaults.standard.MGLMapboxMetricsEnabled = false
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "MGLMapboxMetricsEnabled"), false)

        UserDefaults.standard.set(true, forKey: "MGLMapboxMetricsEnabled")
        XCTAssertEqual(UserDefaults.standard.MGLMapboxMetricsEnabled, true)

        UserDefaults.standard.set(false, forKey: "MGLMapboxMetricsEnabled")
        XCTAssertEqual(UserDefaults.standard.MGLMapboxMetricsEnabled, false)
    }

    func testMGLMapboxMetricsModifiesMMECollectionDisabled() {
        UserDefaults.standard.MGLMapboxMetricsEnabled = false

        // When 'MGLMapboxMetricsEnabled' assigned to 'true' 'MMECollectionDisabled' should became 'false'
        let falseExpectation = keyValueObservingExpectation(for: UserDefaults.mme_configuration(), keyPath: "MMECollectionDisabled", expectedValue: false)
        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        wait(for: [falseExpectation], timeout: 1)

        // When 'MGLMapboxMetricsEnabled' assigned to 'false' 'MMECollectionDisabled' should became 'true'
        let trueExpectation = keyValueObservingExpectation(for: UserDefaults.mme_configuration(), keyPath: "MMECollectionDisabled", expectedValue: true)
        UserDefaults.standard.MGLMapboxMetricsEnabled = false
        wait(for: [trueExpectation], timeout: 1)
    }
}
