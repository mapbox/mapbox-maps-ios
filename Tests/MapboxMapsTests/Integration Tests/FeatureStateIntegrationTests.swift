import XCTest
@testable import MapboxMaps

internal class FeatureStateIntegrationTests: MapViewIntegrationTestCase {

    internal func testSetFeatureState() {
        mapView.mapboxMap.styleURI = .streets
        let featureStateExpectation = XCTestExpectation(description: "Wait for feature state map to be updated and returned.")
        featureStateExpectation.assertForOverFulfill = true

        didFinishLoadingStyle = { mapView in

            do {
                try mapView.mapboxMap.addSource(self.makeGeoJSONSource())
                try mapView.mapboxMap.addLayer(self.makeLayer())

            } catch {
                XCTFail("Failed to add geojson source / layer due to error: \(error)")
            }
        }

        didBecomeIdle = { mapView in
            mapView.mapboxMap.setFeatureState(sourceId: .testSource, featureId: "0", state: ["testKey": true]) { result in
                switch result {
                case .success:
                    mapView.mapboxMap.getFeatureState(sourceId: .testSource, featureId: "0") { result in
                        switch result {
                        case .success(let map):
                            XCTAssertEqual(map["testKey"] as? Bool, true)
                            featureStateExpectation.fulfill()
                        case .failure(let error):
                            XCTFail("Could not retrieve feature state: \(error)")
                        }
                    }
                case .failure(let error):
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }
        }

        wait(for: [featureStateExpectation], timeout: 5.0)
    }

    internal func testRemoveFeatureState() {
        mapView.mapboxMap.styleURI = .streets
        let featureStateRemovedExpectation = XCTestExpectation(description: "Wait for feature state map to be updated and removed.")
        let featureStateKeptExpectation = XCTestExpectation(description: "Wait for feature state map to be kept.")

        didFinishLoadingStyle = { mapView in
            do {
                try mapView.mapboxMap.addSource(self.makeGeoJSONSource())
                try mapView.mapboxMap.addLayer(self.makeLayer())
            } catch {
                XCTFail("Failed to add geojson source / layer due to error: \(error)")
            }
        }

        didBecomeIdle = { mapView in
            mapView.mapboxMap.setFeatureState(sourceId: .testSource, featureId: "0", state: ["testKey": true]) { result in
                if case .failure(let error) = result {
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }

            mapView.mapboxMap.setFeatureState(sourceId: .testSource, featureId: "1", state: ["testKey": true]) { result in
                if case .failure(let error) = result {
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }

            mapView.mapboxMap.removeFeatureState(sourceId: .testSource, featureId: "0") { result in
                switch result {
                case .success:
                    mapView.mapboxMap.getFeatureState(
                        sourceId: .testSource,
                        featureId: "0") { result in

                            switch result {
                            case .success(let map):
                                XCTAssert(map.isEmpty)
                                featureStateRemovedExpectation.fulfill()
                            case .failure(let error):
                                XCTFail("Could not retrieve feature state: \(error)")
                            }
                        }

                    // Removal should only affect the feature with the passed featureId
                    mapView.mapboxMap.getFeatureState(sourceId: .testSource, featureId: "1") { result in
                        switch result {
                        case .success(let map):
                            XCTAssertEqual(map["testKey"] as? Bool, true)
                            featureStateKeptExpectation.fulfill()
                        case .failure(let error):
                            XCTFail("Could not retrieve feature state: \(error)")
                        }
                    }
                case .failure(let error):
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }
        }

        wait(for: [featureStateRemovedExpectation, featureStateKeptExpectation], timeout: 5.0)
    }

    internal func testResetFeatureStates() {
        mapView.mapboxMap.styleURI = .streets
        let featureStateRemovedExpectation = XCTestExpectation(description: "Wait for feature state map to be updated and removed.")
        featureStateRemovedExpectation.expectedFulfillmentCount = 2

        didFinishLoadingStyle = { mapView in
            do {
                try mapView.mapboxMap.addSource(
                    self.makeGeoJSONSource())
                try mapView.mapboxMap.addLayer(
                    self.makeLayer())
            } catch {
                XCTFail("Failed to add geojson source / layer due to error: \(error)")
            }
        }

        didBecomeIdle = { mapView in
            mapView.mapboxMap.setFeatureState(sourceId: .testSource, featureId: "0", state: ["testKey": true]) { result in
                if case .failure(let error) = result {
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }

            mapView.mapboxMap.setFeatureState(sourceId: .testSource, featureId: "1", state: ["testKey": true]) { result in
                if case .failure(let error) = result {
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }

            mapView.mapboxMap.resetFeatureStates(sourceId: .testSource) { result in
                switch result {
                case .success:
                    // Reset should remove feature states of all features
                    mapView.mapboxMap.getFeatureState(sourceId: .testSource, featureId: "0") { result in
                        switch result {
                        case .success(let map):
                            XCTAssert(map.isEmpty)
                            featureStateRemovedExpectation.fulfill()
                        case .failure(let error):
                            XCTFail("Could not retrieve feature state: \(error)")
                        }
                    }

                    mapView.mapboxMap.getFeatureState(sourceId: .testSource, featureId: "1") { result in
                        switch result {
                        case .success(let map):
                            XCTAssert(map.isEmpty)
                            featureStateRemovedExpectation.fulfill()
                        case .failure(let error):
                            XCTFail("Could not retrieve feature state: \(error)")
                        }
                    }
                case .failure(let error):
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }
        }

        wait(for: [featureStateRemovedExpectation], timeout: 5.0)
    }

    // MARK: - Helper

    fileprivate func makeGeoJSONSource() -> GeoJSONSource {

        let coord = CLLocationCoordinate2D(latitude: 14.765625,
                                           longitude: 26.194876675795218)
        let point = Point(coord)
        let feature = Feature(geometry: point)

        var geojsonSource = GeoJSONSource(id: .testSource)
        geojsonSource.generateId = true
        geojsonSource.data = .feature(feature)

        return geojsonSource
    }

    fileprivate func makeLayer() -> SymbolLayer {
        var symbolLayer = SymbolLayer(id: "test-layer", source: .testSource)
        symbolLayer.textField = .constant("test")

        return symbolLayer
    }
}

private extension String {
    static let testSource = "test-source"
}
