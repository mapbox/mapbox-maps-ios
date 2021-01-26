import XCTest
@testable import MapboxMaps

internal class FeatureQueryingTest: MapViewIntegrationTestCase {

    // MARK: - Test querying a rendered map for features.

    /**
     The purpose of this test is to ensure features are returned when querying
     a default style. It does this zooming into an area with dense features,
     and querying the center of the map to ensure there is a populated array of
     features returned.
     */

    // Seattle's Pike Place Market
    let centerCoordinate = CLLocationCoordinate2D(latitude: 47.609519,
                                                  longitude: -122.341647)

    internal func testQueryAtPoint() {
        style?.styleURL = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for features to be queried.")

        didFinishLoadingStyle = { mapView in
            let cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
            cameraManager.setCamera(centerCoordinate: self.centerCoordinate,
                                    zoom: 15.0)
        }

        didBecomeIdle = { mapView in
            // Given
            let centerPoint = mapView.center

            // When
            mapView.visibleFeatures(at: centerPoint, completion: { result in
                // Then
                switch result {
                case .success(let features):
                    if features.count > 0 {
                        featureQueryExpectation.fulfill()
                    } else {
                        XCTFail("No features found")
                    }
                case .failure:
                    XCTFail("Feature querying failed")
                }
            })
        }

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }

    internal func testQueryInRectWithFilter() {
        style?.styleURL = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for features to be queried.")

        didFinishLoadingStyle = { mapView in
            let cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
            cameraManager.setCamera(centerCoordinate: self.centerCoordinate,
                                    zoom: 15.0)
        }

        didBecomeIdle = { mapView in
            // Given
            let queryRect = CGRect(x: mapView.center.x - 25,
                                   y: mapView.center.y - 25,
                                   width: 50,
                                   height: 50)

            // When
            mapView.visibleFeatures(in: queryRect, completion: { unfilteredFeatures in
                let filter = Exp(.eq) {
                    "$type"
                    "Point"
                }
                mapView.visibleFeatures(in: queryRect, filter: filter, completion: { filteredFeatures in
                    if case .success(let unfilteredFeatures) = unfilteredFeatures,
                       case .success(let filteredFeatures) = filteredFeatures {

                        let expectedFilteredFeatures = unfilteredFeatures.filter { feature in
                            return feature.geometry.type == .Point
                        }

                        // Then
                        if expectedFilteredFeatures.count == filteredFeatures.count {
                            featureQueryExpectation.fulfill()
                        } else {
                            XCTFail("Expected \(expectedFilteredFeatures.count) features, got \(filteredFeatures.count) instead.")
                        }
                    } else {
                        XCTFail("Feature querying failed.")
                    }

                })
            })
        }

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }
}
