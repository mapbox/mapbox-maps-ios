import XCTest
@testable import MapboxMaps
import Foundation
import UIKit

class AttributionDialogTests: XCTestCase {

    var attributionDialogManager: AttributionDialogManager!
    var mockDataSource: MockAttributionDataSource!
    var mockDelegate: MockAttributionDialogManagerDelegate!

    override func setUp() {
        super.setUp()
        mockDataSource = MockAttributionDataSource()
        mockDelegate = MockAttributionDialogManagerDelegate()
        attributionDialogManager = AttributionDialogManager(dataSource: mockDataSource, delegate: mockDelegate)
    }

    override func tearDown() {
        super.tearDown()

        attributionDialogManager = nil
        mockDataSource = nil
        mockDelegate = nil
    }

    func testShowTelemetryDialogMetricsEnabled() throws {
        let viewController = UIViewController()
        let bundle = Bundle.mapboxMaps
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        attributionDialogManager.isMetricsEnabled = true

        attributionDialogManager.showTelemetryAlertController(from: viewController)

        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        let telemetryTitle = NSLocalizedString("TELEMETRY_TITLE",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               comment: "")
        XCTAssertEqual(alert.title, telemetryTitle)

        let message = NSLocalizedString("TELEMETRY_ENABLED_MSG",
                                        tableName: Ornaments.localizableTableName,
                                        bundle: bundle,
                                        comment: "")
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let moreTitle = NSLocalizedString("TELEMETRY_MORE",
                                          tableName: Ornaments.localizableTableName,
                                          bundle: bundle,
                                          comment: "")
        XCTAssertEqual(alert.actions[0].title, moreTitle)

        let declineTitle = NSLocalizedString("TELEMETRY_ENABLED_OFF",
                                             tableName: Ornaments.localizableTableName,
                                             bundle: bundle,
                                             comment: "")
        XCTAssertEqual(alert.actions[1].title, declineTitle)

        let participateTitle = NSLocalizedString("TELEMETRY_ENABLED_ON",
                                                 tableName: Ornaments.localizableTableName,
                                                 bundle: bundle,
                                                 comment: "")
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
        let telemetryTitle = NSLocalizedString("TELEMETRY_TITLE",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               comment: "")
        XCTAssertEqual(alert.title, telemetryTitle)

        let message = NSLocalizedString("TELEMETRY_DISABLED_MSG",
                                        tableName: Ornaments.localizableTableName,
                                        bundle: bundle,
                                        comment: "")
        XCTAssertEqual(alert.message, message)

        guard alert.actions.count == 3 else {
            XCTFail("Telemetry alert should have 3 actions")
            return
        }

        let moreTitle = NSLocalizedString("TELEMETRY_MORE",
                                          tableName: Ornaments.localizableTableName,
                                          bundle: bundle,
                                          comment: "")
        XCTAssertEqual(alert.actions[0].title, moreTitle)

        let declineTitle = NSLocalizedString("TELEMETRY_DISABLED_OFF",
                                             tableName: Ornaments.localizableTableName,
                                             bundle: bundle,
                                             comment: "")
        XCTAssertEqual(alert.actions[1].title, declineTitle)

        let participateTitle = NSLocalizedString("TELEMETRY_DISABLED_ON",
                                                 tableName: Ornaments.localizableTableName,
                                                 bundle: bundle,
                                                 comment: "")
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

        let telemetryTitle = NSLocalizedString("TELEMETRY_NAME",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               comment: "")
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
