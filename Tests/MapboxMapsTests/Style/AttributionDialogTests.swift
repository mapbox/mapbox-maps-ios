import XCTest
@_spi(Restricted) @testable import MapboxMaps
import Foundation
import UIKit

class AttributionDialogTests: XCTestCase {
    var parentViewController: MockParentViewController!
    var attributionDialogManager: AttributionDialogManager!
    var attributionMenu: AttributionMenu!
    var urlOpener: AttributionURLOpener!
    var mockDataSource: MockAttributionDataSource!
    var isGeofencingActive = false
    private var isGeofenceActive: Bool = false
    private var isGeofenceConsentGiven: Bool = true

    override func setUp() {
        super.setUp()

        parentViewController = MockParentViewController()
        mockDataSource = MockAttributionDataSource()
        urlOpener = MockAttributionURLOpener()
        attributionMenu = AttributionMenu(
            urlOpener: urlOpener,
            feedbackURLRef: Ref { nil },
            geofencingIsActiveRef: Ref { [unowned self] in self.isGeofenceActive }
        )
        attributionMenu.isGeofencingEnabled = true
        attributionDialogManager = AttributionDialogManager(
            dataSource: mockDataSource,
            delegate: self,
            attributionMenu: attributionMenu
        )
    }

    override func tearDown() {
        super.tearDown()

        attributionMenu.isGeofencingEnabled = true
        isGeofenceActive = false
        parentViewController = nil
        attributionMenu = nil
        urlOpener = nil
        attributionDialogManager = nil
        mockDataSource = nil
    }

    func testGeofencingOptIn() throws {
        attributionMenu.isGeofencingEnabled = false
        isGeofenceActive = true
        attributionMenu.filter = { $0.category == .geofencing }

        attributionDialogManager.didTap(InfoButtonOrnament())

        var infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        XCTAssertNotNil(infoAlert)
        infoAlert.tapButton(atIndex: 0)

        var geofencingAlert = try XCTUnwrap(parentViewController.currentAlert, "The geofencing alert controller could not be found.")

        XCTAssertEqual(geofencingAlert.title, GeofencingStrings.geofencingTitle)
        XCTAssertEqual(geofencingAlert.message, GeofencingStrings.geofencingMessage)

        guard geofencingAlert.actions.count == 2 else {
            XCTFail("Geofencing alert should have 2 actions")
            return
        }

        XCTAssertEqual(GeofencingStrings.geofencingDisabledOffMessage, geofencingAlert.actions[0].title)
        XCTAssertEqual(GeofencingStrings.geofencingDisabledOnMessage, geofencingAlert.actions[1].title)
        XCTAssertFalse(attributionMenu.isGeofencingEnabled)

        geofencingAlert.tapButton(atIndex: 1)
        XCTAssertTrue(attributionMenu.isGeofencingEnabled)

        attributionDialogManager.didTap(InfoButtonOrnament())

        infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        infoAlert.tapButton(atIndex: 0)
        geofencingAlert = try XCTUnwrap(parentViewController.currentAlert, "The geofencing alert controller could not be found.")

        XCTAssertEqual(GeofencingStrings.geofencingEnabledOffMessage, geofencingAlert.actions[0].title)
        XCTAssertEqual(GeofencingStrings.geofencingEnabledOnMessage, geofencingAlert.actions[1].title)

        geofencingAlert.tapButton(atIndex: 1)
        XCTAssertTrue(attributionMenu.isGeofencingEnabled)
    }

    func testGeofencingOptOut() throws {
        attributionMenu.isGeofencingEnabled = true
        isGeofenceActive = true
        attributionMenu.filter = { $0.category == .geofencing }

        attributionDialogManager.didTap(InfoButtonOrnament())

        var infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        XCTAssertNotNil(infoAlert)
        infoAlert.tapButton(atIndex: 0)

        var geofencingAlert = try XCTUnwrap(parentViewController.currentAlert, "The geofencing alert controller could not be found.")

        XCTAssertEqual(geofencingAlert.title, GeofencingStrings.geofencingTitle)
        XCTAssertEqual(geofencingAlert.message, GeofencingStrings.geofencingMessage)

        guard geofencingAlert.actions.count == 2 else {
            XCTFail("Geofencing alert should have 2 actions")
            return
        }

        XCTAssertEqual(GeofencingStrings.geofencingEnabledOffMessage, geofencingAlert.actions[0].title)
        XCTAssertEqual(GeofencingStrings.geofencingEnabledOnMessage, geofencingAlert.actions[1].title)
        XCTAssertTrue(attributionMenu.isGeofencingEnabled)

        geofencingAlert.tapButton(atIndex: 0)
        XCTAssertFalse(attributionMenu.isGeofencingEnabled)

        attributionDialogManager.didTap(InfoButtonOrnament())

        infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        infoAlert.tapButton(atIndex: 0)
        geofencingAlert = try XCTUnwrap(parentViewController.currentAlert, "The geofencing alert controller could not be found.")

        XCTAssertEqual(GeofencingStrings.geofencingDisabledOffMessage, geofencingAlert.actions[0].title)
        XCTAssertEqual(GeofencingStrings.geofencingDisabledOnMessage, geofencingAlert.actions[1].title)

        geofencingAlert.tapButton(atIndex: 0)
        XCTAssertFalse(attributionMenu.isGeofencingEnabled)
    }

    func testShowAttributionDialogNoAttributions() throws {
        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
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
                                            bundle: .mapboxMaps,
                                            value: "Cancel",
                                            comment: "")
        XCTAssertEqual(alert.actions[2].title, cancelTitle)
    }

    func testShowAttributionDialogSingleNonActionableAttribution() throws {
//        attributionMenu.filter = { $0.id == .copyright }
        let attribution = Attribution(title: String.randomASCII(withLength: 10), url: nil)

        mockDataSource.attributions = [attribution]

        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
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
        let attribution0 = Attribution(title: String.randomASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.randomASCII(withLength: 10), url: URL(string: "http://example.com")!)

        mockDataSource.attributions = [attribution0, attribution1]

        attributionDialogManager.didTap(InfoButtonOrnament())

        let alert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
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

    func testAttributionFilteringID() throws {
        let attribution0 = Attribution(title: String.randomASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.randomASCII(withLength: 10), url: URL(string: "http://example.com")!)

        mockDataSource.attributions = [attribution0, attribution1]

        attributionMenu.filter = { $0.id == .copyright || $0.id == .privacyPolicy }

        attributionDialogManager.didTap(.init())

        let alert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")

        // Single, non-actionable attributions should be displayed as alert's actions along the telemetry and cancel actions
        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let privacyPolicyTitle = NSLocalizedString("ATTRIBUTION_PRIVACY_POLICY",
                                                   tableName: Ornaments.localizableTableName,
                                                   bundle: .mapboxMaps,
                                                   value: "Mapbox Privacy Policy",
                                                   comment: "Privacy policy action in attribution sheet")

        XCTAssertEqual(alert.actions[0].title, attribution0.title)
        XCTAssertEqual(alert.actions[1].title, attribution1.title)
        XCTAssertEqual(alert.actions[2].title, privacyPolicyTitle)
    }

    func testAttributionFilteringCategory() throws {
        isGeofenceActive = true
        let attribution0 = Attribution(title: String.randomASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.randomASCII(withLength: 10), url: URL(string: "http://example.com")!)

        mockDataSource.attributions = [attribution0, attribution1]

        attributionMenu.filter = { $0.category == .telemetry || $0.category == .geofencing }

        attributionDialogManager.didTap(.init())

        let alert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")

        // Single, non-actionable attributions should be displayed as alert's actions along the telemetry and cancel actions
        guard alert.actions.count == 2 else {
            XCTFail("Telemetry alert should have 2 actions")
            return
        }

        XCTAssertEqual(alert.actions[0].title, TelemetryStrings.telemetryName)
        XCTAssertEqual(alert.actions[1].title, GeofencingStrings.geofencingName)
    }

}

extension AttributionDialogTests: AttributionDialogManagerDelegate {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController? {
        return parentViewController
    }
}
