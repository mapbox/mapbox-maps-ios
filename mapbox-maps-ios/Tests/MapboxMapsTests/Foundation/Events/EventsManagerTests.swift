import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class EventsManagerTests: XCTestCase {

    var eventsManager: EventsManagerProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        eventsManager = EventsManager()
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

        XCTAssertEqual(UserDefaults.standard.MGLMapboxMetricsEnabled, !initialValue)
        XCTAssertEqual(TelemetryUtils.getEventsCollectionState(), !initialValue)
    }

    func testMGLMapboxMetricsModifiesTelemetryCollectionState() {
        UserDefaults.standard.MGLMapboxMetricsEnabled = false

        XCTAssertFalse(TelemetryUtils.getEventsCollectionState())

        UserDefaults.standard.MGLMapboxMetricsEnabled = true

        XCTAssertTrue(TelemetryUtils.getEventsCollectionState())

        UserDefaults.standard.MGLMapboxMetricsEnabled = false

        XCTAssertFalse(TelemetryUtils.getEventsCollectionState())
    }
}
