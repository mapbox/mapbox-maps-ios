import XCTest
@testable import MapboxMaps

class MapboxInfoButtonOrnamentTests: XCTestCase {

    func testInfoButtonTapped() throws {
        let infoButton = MapboxInfoButtonOrnament()
        let parentViewController = MockParentViewController()
        parentViewController.view.addSubview(infoButton)
        infoButton.infoTapped()

        let firstAlert = try XCTUnwrap(parentViewController.currentAlert, "The first alert controller could not be found.")
        XCTAssertNotNil(firstAlert)

        XCTAssertEqual(firstAlert.actions.count, 2, "There should be two alerts present.")
        let telemetryTitle = NSLocalizedString("Mapbox Telemetry", comment: "Action in attribution sheet")
        XCTAssertEqual(firstAlert.actions[0].title!, telemetryTitle)

        let cancelTitle = NSLocalizedString("Cancel", comment: "Title of button for dismissing attribution action sheet")
        XCTAssertEqual(firstAlert.actions[1].title, cancelTitle)
    }

    func testTelemetryOptOut() throws {
        let infoButton = MapboxInfoButtonOrnament()
        let parentViewController = MockParentViewController()
        parentViewController.view.addSubview(infoButton)
        UserDefaults.standard.set(true, forKey: Ornaments.metricsEnabledKey)
        infoButton.infoTapped()

        var infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        XCTAssertNotNil(infoAlert)
        infoAlert.tapButton(atIndex: 0)

        var telemetryAlert = try XCTUnwrap(parentViewController.currentAlert, "The telemetry alert controller could not be found.")

        XCTAssertEqual(telemetryAlert.actions.count, 3, "The telemetry alert should have 3 actions.")

        let participatingTitle = NSLocalizedString("Keep Participating", comment: "Telemetry prompt button")
        XCTAssertEqual(participatingTitle, telemetryAlert.actions[2].title, "The third action should be a 'Keep Participating' button.")

        XCTAssertTrue(infoButton.isMetricsEnabled)

        let stopParticipatingTitle = NSLocalizedString("Stop Participating", comment: "Telemetry prompt button")
        XCTAssertEqual(stopParticipatingTitle, telemetryAlert.actions[1].title, "The second action should be a 'Stop Participating' button.")

        telemetryAlert.tapButton(atIndex: 1)
        XCTAssertFalse(infoButton.isMetricsEnabled, "Metrics should not be enabled after selecting 'Stop participating'.")

        infoButton.infoTapped()
        infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        infoAlert.tapButton(atIndex: 0)

        telemetryAlert = try XCTUnwrap(parentViewController.currentAlert, "The telemetry alert controller could not be found.")
        let dontParticipateTitle = NSLocalizedString("Don’t Participate", comment: "Telemetry prompt button")
        XCTAssertEqual(dontParticipateTitle, telemetryAlert.actions[1].title, "The second action should be a 'Don't Participate' button.")
        telemetryAlert.tapButton(atIndex: 1)
        XCTAssertFalse(infoButton.isMetricsEnabled, "Metrics should not be enabled after selecting 'Don't Participate'.")
    }

    func testTelemetryOptIn() throws {
        UserDefaults.standard.set(false, forKey: Ornaments.metricsEnabledKey)
        let infoButton = MapboxInfoButtonOrnament()
        let parentViewController = MockParentViewController()
        parentViewController.view.addSubview(infoButton)
        infoButton.infoTapped()

        var infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        XCTAssertNotNil(infoAlert)
        infoAlert.tapButton(atIndex: 0)

        var telemetryAlert = try XCTUnwrap(parentViewController.currentAlert, "The telemetry alert controller could not be found.")

        XCTAssertEqual(telemetryAlert.actions.count, 3, "The telemetry alert should have 3 actions.")

        let participatingTitle = NSLocalizedString("Participate", comment: "Telemetry prompt button")
        XCTAssertEqual(participatingTitle, telemetryAlert.actions[2].title, "The third action should be a 'Participate' button.")

        XCTAssertFalse(infoButton.isMetricsEnabled)

        let dontParticipateTitle = NSLocalizedString("Don’t Participate", comment: "Telemetry prompt button")
        XCTAssertEqual(dontParticipateTitle, telemetryAlert.actions[1].title, "The second action should be a 'Don't Participate' button.")

        telemetryAlert.tapButton(atIndex: 2)
        XCTAssertTrue(infoButton.isMetricsEnabled, "Metrics should be enabled after selecting 'Participate'.")

        infoButton.infoTapped()
        infoAlert = try XCTUnwrap(parentViewController.currentAlert, "The info alert controller could not be found.")
        infoAlert.tapButton(atIndex: 0)
        telemetryAlert = try XCTUnwrap(parentViewController.currentAlert, "The telemetry alert controller could not be found.")
        let keepParticipatingTitle = NSLocalizedString("Keep Participating", comment: "Telemetry prompt button")
        XCTAssertEqual(keepParticipatingTitle, telemetryAlert.actions[2].title, "The third action should be a 'Keep Participating' button.")
        telemetryAlert.tapButton(atIndex: 2)
        XCTAssertTrue(infoButton.isMetricsEnabled, "Metrics should be enabled after selecting 'Keep Participating'.")
    }
}

class MockParentViewController: UIViewController {
    var currentAlert: UIAlertController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let vc = viewControllerToPresent as? UIAlertController {
            currentAlert = vc
        }
    }
}

// From https://stackoverflow.com/questions/36173740/trigger-uialertaction-on-uialertcontroller-programmatically
extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}
