import XCTest
@testable import MapboxMaps
import Foundation
import UIKit

class AttributionDialogTests: XCTestCase {
    var attributionDialogManager: AttributionDialogManager!
    var mockDataSource: MockAttributionDataSource!
    var mockDelegate: MockAttributionDialogManagerDelegate!
    private var isGeofenceActive: Bool = false
    private var isGeofenceConsentGiven: Bool = true

    override func setUp() {
        super.setUp()
        mockDataSource = MockAttributionDataSource()
        mockDelegate = MockAttributionDialogManagerDelegate()
        attributionDialogManager = AttributionDialogManager(
            dataSource: mockDataSource,
            delegate: mockDelegate,
            isGeofenceActive: { self.isGeofenceActive },
            setGeofenceConsent: { self.isGeofenceConsentGiven = $0 },
            getGeofenceConsent: { self.isGeofenceConsentGiven }
        )
    }

    override func tearDown() {
        super.tearDown()

        attributionDialogManager = nil
        mockDataSource = nil
        mockDelegate = nil
    }

    func testShowGeofencingDialogGeofencingEnabled() throws {
        let viewController = UIViewController()
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        isGeofenceConsentGiven = true

        attributionDialogManager.showGeofencingAlertController(from: viewController)

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let geofenceTitle = GeofencingStrings.geofencingTitle
        XCTAssertEqual(alert.title, geofenceTitle)

        let message = GeofencingStrings.geofencingMessage
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 2 else {
            XCTFail("Telemetry alert should have 2 actions")
            return
        }

        let declineTitle = GeofencingStrings.geofencingEnabledOffMessage
        XCTAssertEqual(alert.actions[0].title, declineTitle)

        let participateTitle = GeofencingStrings.geofencingEnabledOnMessage
        XCTAssertEqual(alert.actions[1].title, participateTitle)
    }

    func testShowGeofencingDialogGeofencingDisabled() throws {
        let viewController = UIViewController()
        let bundle = Bundle.mapboxMaps
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        isGeofenceConsentGiven = false

        attributionDialogManager.showGeofencingAlertController(from: viewController)

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let geofenceTitle = GeofencingStrings.geofencingTitle
        XCTAssertEqual(alert.title, geofenceTitle)

        let message = GeofencingStrings.geofencingMessage
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 2 else {
            XCTFail("Telemetry alert should have 2 actions")
            return
        }

        let declineTitle = GeofencingStrings.geofencingDisabledOffMessage
        XCTAssertEqual(alert.actions[0].title, declineTitle)

        let participateTitle = GeofencingStrings.geofencingDisabledOnMessage
        XCTAssertEqual(alert.actions[1].title, participateTitle)
    }

    func testShowTelemetryDialogMetricsEnabled() throws {
        let viewController = UIViewController()
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        attributionDialogManager.isMetricsEnabled = true

        attributionDialogManager.showTelemetryAlertController(from: viewController)

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let telemetryTitle = TelemetryStrings.telemetryTitle
        XCTAssertEqual(alert.title, telemetryTitle)

        let message = TelemetryStrings.telemetryEnabledMessage
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let moreTitle = TelemetryStrings.telemetryMore
        XCTAssertEqual(alert.actions[0].title, moreTitle)

        let declineTitle = TelemetryStrings.telemetryEnabledOffMessage
        XCTAssertEqual(alert.actions[1].title, declineTitle)

        let participateTitle = TelemetryStrings.telemetryEnabledOnMessage
        XCTAssertEqual(alert.actions[2].title, participateTitle)
    }

    func testShowTelemetryDialogMetricsDisabled() throws {
        let viewController = UIViewController()
        let bundle = Bundle.mapboxMaps
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        attributionDialogManager.isMetricsEnabled = false

        attributionDialogManager.showTelemetryAlertController(from: viewController)

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let telemetryTitle = TelemetryStrings.telemetryTitle
        XCTAssertEqual(alert.title, telemetryTitle)

        let message = TelemetryStrings.telemetryDisabledMessage
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let moreTitle = TelemetryStrings.telemetryMore
        XCTAssertEqual(alert.actions[0].title, moreTitle)

        let declineTitle = TelemetryStrings.telemetryDisabledOffMessage
        XCTAssertEqual(alert.actions[1].title, declineTitle)

        let participateTitle = TelemetryStrings.telemetryDisabledOnMessage
        XCTAssertEqual(alert.actions[2].title, participateTitle)
    }

    func testShowAttributionDialogNoAttributions() throws {
        let viewController = UIViewController()
        let bundle = Bundle.mapboxMaps
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        mockDelegate.viewControllerForPresentingStub.defaultReturnValue = viewController

        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let alertTitle = NSLocalizedString("SDK_NAME",
                                           tableName: nil,
                                           value: "Powered by Mapbox Maps",
                                           comment: "")
        XCTAssertEqual(alert.title, alertTitle)
        XCTAssertNil(alert.message)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let telemetryTitle = TelemetryStrings.telemetryName
        XCTAssertEqual(alert.actions[0].title, telemetryTitle)

        XCTAssertEqual(alert.actions[1].title, Attribution.makePrivacyPolicyAttribution().title)

        let cancelTitle = NSLocalizedString("CANCEL",
                                            tableName: Ornaments.localizableTableName,
                                            bundle: bundle,
                                            value: "Cancel",
                                            comment: "")
        XCTAssertEqual(alert.actions[2].title, cancelTitle)
    }

    func testShowAttributionDialogSingleNonActionableAttribution() throws {
        let viewController = UIViewController()
        let window = UIWindow()
        let attribution = Attribution(title: String.randomASCII(withLength: 10), url: nil)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        mockDataSource.loadAttributionsStub.defaultSideEffect = { invocation in
            invocation.parameters([attribution])
        }
        mockDelegate.viewControllerForPresentingStub.defaultReturnValue = viewController

        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let alertTitle = NSLocalizedString("SDK_NAME",
                                           tableName: nil,
                                           value: "Powered by Mapbox Maps",
                                           comment: "")

        // Alert dialog should still have just the telemetry and cancel actions
        // Single, non-actionable attribution should be displayed as alert's message
        XCTAssertEqual(alert.title, alertTitle)
        XCTAssertEqual(alert.message, attribution.title)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }
    }

    func testShowAttributionDialogTwoAttributions() throws {
        let viewController = UIViewController()
        let window = UIWindow()
        let attribution0 = Attribution(title: String.randomASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.randomASCII(withLength: 10), url: URL(string: "http://example.com")!)

        window.rootViewController = viewController
        window.makeKeyAndVisible()
        mockDataSource.loadAttributionsStub.defaultSideEffect = { invocation in
            invocation.parameters([attribution0, attribution1])
        }
        mockDelegate.viewControllerForPresentingStub.defaultReturnValue = viewController

        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let alertTitle = NSLocalizedString("SDK_NAME",
                                           tableName: nil,
                                           value: "Powered by Mapbox Maps",
                                           comment: "")

        XCTAssertEqual(alert.title, alertTitle)
        XCTAssertNil(alert.message)

        // Single, non-actionable attributions should be displayed as alert's actions along the telemetry and cancel actions
        guard alert.actions.count == 5 else {
            XCTFail("Telemetry alert should have 5 actions")
            return
        }

        XCTAssertEqual(alert.actions[0].title, attribution0.title)
        XCTAssertEqual(alert.actions[1].title, attribution1.title)
    }
}
