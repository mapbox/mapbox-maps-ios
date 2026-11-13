import XCTest
import SwiftUI
@_spi(Restricted) @testable import MapboxMaps

class InfoButtonOrnamentTests: XCTestCase {

    var parentViewController: MockParentViewController!
    var attributionDialogManager: AttributionDialogManager!
    var urlOpener: AttributionURLOpener!
    var attributionMenu: AttributionMenu!
    var tapCompletion: (() -> Void)?

    private var isGeofenceActive: Bool = false
    private var isGeofenceConsentGiven: Bool = true

    override func setUp() {
        super.setUp()
        parentViewController = MockParentViewController()
        urlOpener = MockAttributionURLOpener()
        attributionMenu = AttributionMenu(urlOpener: urlOpener, feedbackURLRef: Ref { nil })
        attributionDialogManager = AttributionDialogManager(
            dataSource: self,
            delegate: self,
            attributionMenu: attributionMenu
        )
    }

    override func tearDown() {
        urlOpener = nil
        attributionMenu = nil
        parentViewController = nil
        attributionDialogManager = nil
        super.tearDown()
    }

    func testInfoButtonTapped() throws {
        let infoButton = InfoButtonOrnament()
        infoButton.delegate = attributionDialogManager

        parentViewController.view.addSubview(infoButton)
        infoButton.infoTapped()

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet,
                                  "An AttributionSheetView should be presented.")
        XCTAssertGreaterThan(sheet.rowCount, 0)
    }

    func testTelemetryOptOut() throws {
        let infoButton = InfoButtonOrnament()
        infoButton.delegate = attributionDialogManager

        parentViewController.view.addSubview(infoButton)
        UserDefaults.standard.MGLMapboxMetricsEnabled = true
        infoButton.infoTapped()

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertTrue(sheet.toggleIsOn(for: .telemetry), "Switch should be on when metrics enabled")

        sheet.simulateToggle(false, for: .telemetry)
        XCTAssertFalse(UserDefaults.standard.MGLMapboxMetricsEnabled,
                       "Metrics should be disabled after toggling switch off")

        infoButton.infoTapped()
        let sheet2 = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertFalse(sheet2.toggleIsOn(for: .telemetry), "Switch should be off after metrics disabled")
    }

    func testTelemetryOptIn() throws {
        UserDefaults.standard.MGLMapboxMetricsEnabled = false
        let infoButton = InfoButtonOrnament()
        infoButton.delegate = attributionDialogManager

        parentViewController.view.addSubview(infoButton)
        infoButton.infoTapped()

        let sheet = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertFalse(sheet.toggleIsOn(for: .telemetry), "Switch should be off when metrics disabled")

        sheet.simulateToggle(true, for: .telemetry)
        XCTAssertTrue(UserDefaults.standard.MGLMapboxMetricsEnabled,
                      "Metrics should be enabled after toggling switch on")

        infoButton.infoTapped()
        let sheet2 = try XCTUnwrap(parentViewController.currentAttributionSheet)
        XCTAssertTrue(sheet2.toggleIsOn(for: .telemetry), "Switch should be on after metrics enabled")
    }
}

extension InfoButtonOrnamentTests: AttributionDataSource {
    func getAttributions() -> [MapboxMaps.Attribution] {
        []
    }
}

extension InfoButtonOrnamentTests: AttributionDialogManagerDelegate {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController? {
        return parentViewController
    }

    func attributionDialogManager(_ attributionDialogManager: AttributionDialogManager, didTriggerActionFor attribution: Attribution) {
        print("Trigger action for \(attribution)")
    }
}

// MARK: - MockParentViewController

class MockParentViewController: UIViewController {
    var currentAttributionSheet: AttributionSheetView?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let host = viewControllerToPresent as? UIHostingController<AttributionSheetView> {
            currentAttributionSheet = host.rootView
        }
    }
}
