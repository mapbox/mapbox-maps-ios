import XCTest
@testable import MapboxMaps

class MapboxInfoButtonOrnamentTests: MapViewIntegrationTestCase {
    func testInfoButton() throws {
        let mapView = try XCTUnwrap(self.mapView, "There should be a map view present.")
        
        let initialSubviews = mapView.subviews.filter { $0 is MapboxInfoButtonOrnament }

        let infoButton = try XCTUnwrap(initialSubviews.first as? MapboxInfoButtonOrnament, "The MapView should include an info button as a subview")
        
        let parentViewController = try XCTUnwrap(infoButton.parentViewController, "")
        
        infoButton.infoTapped()
        
        let expectation = XCTestExpectation(description: "alert controller should exist")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let alertControllers = parentViewController.children
    //            parentViewController.children.filter { $0 is UIAlertController }
            do {
                let alertController = try XCTUnwrap(alertControllers.first, "There should be an alert controller present.")
                expectation.fulfill()
            } catch {
                print("Couldn't find alert controller.")
            }

        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testMetricsEnabled() {
        let infoButton = MapboxInfoButtonOrnament()
        
        XCTAssertFalse(infoButton.isMetricsEnabled, "Metrics should be enabled by default.")
        
//        UserDefaults.standard.set(false, forKey: MapboxInfoButton.Constants.metricsEnabledKey)
    }
}

class MockMapboxInfoButtonOrnament: MapboxInfoButtonOrnament {
    var didTapInfoButton: Bool
    var didShowTelemetryController: Bool

    override func infoTapped() {
        didTapInfoButton = true
    }
    
    override func showTelemetryAlertController() {
        
    }
}
