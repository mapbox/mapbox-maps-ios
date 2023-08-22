import XCTest
@testable import MapboxMaps
import MapboxCoreMaps
import MapboxCommon

// Modified from MapViewIntegrationTestCase
internal class DidIdleFailureIntegrationTest: IntegrationTestCase {

    internal var mapView: MapView?
    internal var dataPathURL: URL!

    internal var hadResourceEventError: ((MapView, ResourceRequestError) -> Void)?

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        try guardForMetalDevice()

        guard let window = window,
              let rootView = rootViewController?.view else {
            XCTFail("No valid UIWindow or root view controller")
            return
        }

        dataPathURL = try temporaryCacheDirectory()

        MapboxMapsOptions.dataPath = dataPathURL
        let view = MapView(frame: window.bounds)

        view.mapboxMap.onResourceRequest.observe { [weak self, weak view] req in
            if let error = req.response?.error, let view = view {
                self?.hadResourceEventError?(view, error)
            }
        }.store(in: &cancelables)

        rootView.addSubview(view)

        view.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true

        mapView = view
    }

    internal override func tearDownWithError() throws {
        mapView?.removeFromSuperview()
        mapView = nil

        let expectation = self.expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        rootViewController?.viewWillDisappear(false)
        rootViewController?.viewDidDisappear(false)
        rootViewController = nil
        window = nil
    }

    internal func testWaitForIdle() throws {
        guard let mapView = mapView else {
            XCTFail("There should be valid MapView object created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Wait for map to idle")
        expectation.expectedFulfillmentCount = 2

        mapView.mapboxMap.styleURI = .streets

        mapView.mapboxMap.onMapLoadingError.observeNext { error in
            XCTFail("Failed to load map with \(String(describing: error))")
        }.store(in: &cancelables)

        mapView.mapboxMap.onStyleLoaded.observe { _ in
            expectation.fulfill()
        }.store(in: &cancelables)

        mapView.mapboxMap.onMapIdle.observeNext { _ in
            expectation.fulfill()
        }.store(in: &cancelables)

        var eventError: ResourceRequestError?
        hadResourceEventError = { _, error in
            eventError = error
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        switch result {
        case .completed:
            break

        case .timedOut:
            if let error = eventError {
                print("Timed out, test had a resource error: \(error.reason) - \(error.message)")
            } else {
                print("Timed out, but no resource error")
            }
            fallthrough

        default:
            XCTFail("Test failed with \(result)")
        }
    }
}
