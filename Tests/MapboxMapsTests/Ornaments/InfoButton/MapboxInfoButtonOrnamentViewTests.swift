import XCTest
@testable import MapboxMaps

class MapboxInfoButtonOrnamentTests: MapViewIntegrationTestCase {
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
    
    func testTelemetryTapped() throws {
        
        UserDefaults.standard.set(true, forKey: MapboxInfoButtonOrnament.Constants.metricsEnabledKey)
        let infoButton = MapboxInfoButtonOrnament()
        let parentViewController = MockParentViewController()
        parentViewController.view.addSubview(infoButton)
        infoButton.infoTapped()
        
        let firstAlert = try XCTUnwrap(parentViewController.currentAlert, "The first alert controller could not be found.")
        XCTAssertNotNil(firstAlert)

        firstAlert.tapButton(atIndex: 0)
        let secondAlert = try XCTUnwrap(parentViewController.currentAlert, "The second alert controller could not be found.")
        
        XCTAssertEqual(secondAlert.actions.count, 3, "The telemetry alert should have 3 actions.")
        
        let cancelTitle = NSLocalizedString( "Keep Participating", comment: "Telemetry prompt button")
        XCTAssertEqual(cancelTitle, secondAlert.actions[2].title, "The third action should be a cancel button.")
        
        XCTAssertTrue(infoButton.isMetricsEnabled)
    }
    
    func testMetricsEnabled() {
        let infoButton = MapboxInfoButtonOrnament()
        
        XCTAssertFalse(infoButton.isMetricsEnabled, "Metrics should be enabled by default.")
        
//        UserDefaults.standard.set(false, forKey: MapboxInfoButton.Constants.metricsEnabledKey)
    }
}

class MockParentViewController: UIViewController {
    var alertCount = 0
    var currentAlert: UIAlertController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let vc = viewControllerToPresent as? UIAlertController {
            currentAlert = vc
            alertCount += 1
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
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        print("BYE")
        super.dismiss(animated: flag, completion: completion)
    }
}
