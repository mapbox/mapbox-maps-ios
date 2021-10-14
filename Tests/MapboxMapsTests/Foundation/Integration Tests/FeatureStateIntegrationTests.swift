import XCTest
import CoreLocation
@testable import MapboxMaps

internal class FeatureStateIntegrationTests: MapViewIntegrationTestCase {

    internal func testSetFeatureState() {
        style?.uri = .streets
        let featureStateExpectation = XCTestExpectation(description: "Wait for feature state  map to be updated.")

        didFinishLoadingStyle = { mapView in

            do {
                try mapView.mapboxMap.style.addSource(
                    self.makeGeoJSONSource(),
                    id: "test-source")
                try mapView.mapboxMap.style.addLayer(
                    self.makeLayer())

            } catch {
                XCTFail("Failed to add geojson source / layer due to error: \(error)")
            }
        }

        didBecomeIdle = { mapView in
            mapView.mapboxMap.setFeatureState(sourceId: "test-source", featureId: "0", state: ["testKey": true])

            mapView.mapboxMap.getFeatureState(sourceId: "test-source", featureId: "0") { result in
                switch result {
                case .success(let map):
                    XCTAssertEqual(map["testKey"] as? Bool, true)
                    featureStateExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }
        }

        wait(for: [featureStateExpectation], timeout: 5.0)
    }

    internal func testRemoveFeatureState() {
        style?.uri = .streets
        let featureStateExpectation = XCTestExpectation(description: "Wait for feature state map to be updated.")

        didFinishLoadingStyle = { mapView in
            do {
                try mapView.mapboxMap.style.addSource(
                    self.makeGeoJSONSource(),
                    id: "test-source")
                try mapView.mapboxMap.style.addLayer(
                    self.makeLayer())
            } catch {
                XCTFail("Failed to add geojson source / layer due to error: \(error)")
            }
        }

        didBecomeIdle = { mapView in
            mapView.mapboxMap.setFeatureState(sourceId: "test-source", featureId: "0", state: ["testKey": true])

            mapView.mapboxMap.removeFeatureState(sourceId: "test-source", featureId: "0")

            mapView.mapboxMap.getFeatureState(
                sourceId: "test-source",
                featureId: "0") { result in

                switch result {
                case .success(let map):
                    XCTAssert(map.isEmpty)
                    featureStateExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Could not retrieve feature state: \(error)")
                }
            }

        }

        wait(for: [featureStateExpectation], timeout: 5.0)
    }

    // MARK: - Helper

    fileprivate func makeGeoJSONSource() -> GeoJSONSource {

        let coord = CLLocationCoordinate2D(latitude: 14.765625,
                                           longitude: 26.194876675795218)
        let point = Point(coord)
        let feature = Feature(geometry: .point(point))

        var geojsonSource = GeoJSONSource()
        geojsonSource.generateId = true
        geojsonSource.data = .feature(feature)

        return geojsonSource
    }

    fileprivate func makeLayer() -> SymbolLayer {
        var symbolLayer = SymbolLayer(id: "test-layer")
        symbolLayer.source = "test-source"
        symbolLayer.textField = .constant("test")

        return symbolLayer
    }
}
