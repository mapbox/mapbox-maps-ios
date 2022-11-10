import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class EventsManagerTests: XCTestCase {

    var eventsManager: EventsManagerProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        eventsManager = try EventsManager(accessToken: mapboxAccessToken())
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

    func testCoreTelemetryMetricsEnabledToggle() {
        let initialValue = UserDefaults.standard.MGLMapboxMetricsEnabled

        UserDefaults.standard.MGLMapboxMetricsEnabled.toggle()

        let exp = expectation(description: "Wait for one runloop run")
        DispatchQueue.main.async {
            XCTAssertEqual(UserDefaults.standard.MGLMapboxMetricsEnabled, !initialValue)
            XCTAssertEqual(TelemetryUtils.getEventsCollectionState(), !initialValue)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testMGLMapboxMetricsModifiesMMECollectionDisabled() {
        UserDefaults.standard.MGLMapboxMetricsEnabled = false

        DispatchQueue.main.async {
            XCTAssertFalse(TelemetryUtils.getEventsCollectionState())
        }

        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        DispatchQueue.main.async {
            XCTAssertTrue(TelemetryUtils.getEventsCollectionState())
        }

        // Wait for a one run in RunLoop to process inner DispatchQueue.main.async closures
        // There is no reason to wait for previous async's since MainQueue is serial
        let exp = expectation(description: "Wait for one runloop run")
        UserDefaults.standard.MGLMapboxMetricsEnabled = false
        DispatchQueue.main.async {
            XCTAssertFalse(TelemetryUtils.getEventsCollectionState())
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
