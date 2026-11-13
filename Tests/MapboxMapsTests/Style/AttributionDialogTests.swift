import XCTest
import SwiftUI
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
        GeofencingConsent.isGiven = true
        attributionDialogManager = AttributionDialogManager(
            dataSource: mockDataSource,
            delegate: self,
            attributionMenu: attributionMenu
        )
    }

    override func tearDown() {
        super.tearDown()

        GeofencingConsent.isGiven = true
        isGeofenceActive = false
        parentViewController = nil
        attributionMenu = nil
        urlOpener = nil
        attributionDialogManager = nil
        mockDataSource = nil
    }

    // MARK: - Geofencing toggle

    func testGeofencingOptIn() throws {
        GeofencingConsent.isGiven = false
        isGeofenceActive = true
        attributionMenu.filter = { $0.id == .geofencing }

        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertFalse(sheet.toggleIsOn(for: .geofencing), "Switch should be off when geofencing disabled")

        sheet.simulateToggle(true, for: .geofencing)
        XCTAssertTrue(GeofencingConsent.isGiven,
                      "Geofencing should be enabled after toggling switch on")

        // Re-open and verify state persists
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet2 = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertTrue(sheet2.toggleIsOn(for: .geofencing))
    }

    func testGeofencingOptOut() throws {
        GeofencingConsent.isGiven = true
        isGeofenceActive = true
        attributionMenu.filter = { $0.id == .geofencing }

        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertTrue(sheet.toggleIsOn(for: .geofencing), "Switch should be on when geofencing enabled")

        sheet.simulateToggle(false, for: .geofencing)
        XCTAssertFalse(GeofencingConsent.isGiven,
                       "Geofencing should be disabled after toggling switch off")

        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet2 = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertFalse(sheet2.toggleIsOn(for: .geofencing))
    }

    // MARK: - Main sheet content

    func testShowAttributionSheetNoAttributions() throws {
        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(sheet.attributionRowCount, 0)
        XCTAssertGreaterThan(sheet.rowCount, 0)
    }

    func testShowAttributionSheetSingleNonActionableAttribution() throws {
        let attribution = Attribution(title: String.testConstantASCII(withLength: 10), url: nil)
        mockDataSource.attributions = [attribution]

        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(sheet.attributionRowCount, 1)
        XCTAssertNil(try XCTUnwrap(sheet.item(.copyright)).url, "Row should be inert")
    }

    func testShowAttributionSheetTwoAttributions() throws {
        let attribution0 = Attribution(title: String.testConstantASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.testConstantASCII(withLength: 10), url: URL(string: "http://example.com")!)
        mockDataSource.attributions = [attribution0, attribution1]

        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(sheet.attributionRowCount, 2)
    }

    // MARK: - Filtering

    func testAttributionFilteringID() throws {
        let attribution0 = Attribution(title: String.testConstantASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.testConstantASCII(withLength: 10), url: URL(string: "http://example.com")!)
        mockDataSource.attributions = [attribution0, attribution1]

        attributionMenu.filter = { $0.id == .copyright || $0.id == .privacyPolicy }
        attributionDialogManager.didTap(.init())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(sheet.attributionRowCount, 2)
    }

    func testAttributionFilteringDropsEmptySections() throws {
        let attribution0 = Attribution(title: String.testConstantASCII(withLength: 10), url: nil)
        let attribution1 = Attribution(title: String.testConstantASCII(withLength: 10), url: URL(string: "http://example.com")!)
        mockDataSource.attributions = [attribution0, attribution1]

        attributionMenu.filter = { $0.id == .telemetry }
        attributionDialogManager.didTap(.init())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(sheet.attributionRowCount, 0, "Filter should remove copyright rows")
        XCTAssertEqual(sheet.rowCount, 1, "Only the telemetry row should remain")
        XCTAssertEqual(sheet.menu.sections.count, 1, "Sections left empty should be dropped")
    }

    @available(*, deprecated)
    func testDeprecatedCategoryShim() throws {
        isGeofenceActive = true
        attributionDialogManager.didTap(.init())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertEqual(try XCTUnwrap(sheet.item(.telemetry)).category, .telemetry)
        XCTAssertEqual(try XCTUnwrap(sheet.item(.geofencing)).category, .geofencing)
        XCTAssertEqual(try XCTUnwrap(sheet.item(.privacyPolicy)).category, .main)
    }

    // MARK: - Telemetry inline controls

    func testTelemetryRowExists() throws {
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        let item = try XCTUnwrap(sheet.item(.telemetry))
        XCTAssertNotNil(item.message, "Telemetry row should have a description")
        XCTAssertNotNil(item.link, "Telemetry description should carry a Learn More link")
        XCTAssertNotNil(item.toggle, "Telemetry row should render a toggle")
    }

    func testTelemetryToggleSyncsState() throws {
        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        XCTAssertTrue(sheet.toggleIsOn(for: .telemetry))
        sheet.simulateToggle(false, for: .telemetry)
        XCTAssertFalse(UserDefaults.standard.MGLMapboxMetricsEnabled)
        XCTAssertFalse(sheet.toggleIsOn(for: .telemetry))
    }

    func testTelemetryMessageFollowsToggleState() throws {
        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        let item = try XCTUnwrap(sheet.item(.telemetry))
        XCTAssertEqual(item.message, TelemetryStrings.telemetryEnabledMessage)
        XCTAssertEqual(item.message(forToggleState: true), TelemetryStrings.telemetryEnabledMessage)
        XCTAssertEqual(item.message(forToggleState: false), TelemetryStrings.telemetryDisabledMessage)
    }

    func testMessageForToggleStateFallsBackToStaticMessage() throws {
        isGeofenceActive = true
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        let item = try XCTUnwrap(sheet.item(.geofencing))
        XCTAssertEqual(item.message(forToggleState: true), GeofencingStrings.geofencingMessage)
        XCTAssertEqual(item.message(forToggleState: false), GeofencingStrings.geofencingMessage)
    }

    // MARK: - Geofencing inline controls

    func testGeofencingRowExists() throws {
        isGeofenceActive = true
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        let item = try XCTUnwrap(sheet.item(.geofencing))
        XCTAssertEqual(item.message, GeofencingStrings.geofencingMessage,
                       "Geofencing row should carry its description")
        XCTAssertNotNil(item.toggle, "Geofencing row should render a toggle")
    }

    func testGeofencingRowHiddenWhenInactiveAndConsented() throws {
        isGeofenceActive = false
        GeofencingConsent.isGiven = true
        attributionDialogManager.didTap(InfoButtonOrnament())

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertNil(sheet.item(.geofencing))
    }

    func testGeofencingToggleSyncsState() throws {
        isGeofenceActive = true
        GeofencingConsent.isGiven = true
        attributionDialogManager.didTap(InfoButtonOrnament())
        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)

        XCTAssertTrue(sheet.toggleIsOn(for: .geofencing))
        sheet.simulateToggle(false, for: .geofencing)
        XCTAssertFalse(GeofencingConsent.isGiven)
        XCTAssertFalse(sheet.toggleIsOn(for: .geofencing))
    }
}

extension AttributionDialogTests: AttributionDialogManagerDelegate {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController? {
        return parentViewController
    }
}
