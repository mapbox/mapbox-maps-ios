// This file is generated
import XCTest
@testable import MapboxMaps

final class HeatmapLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HeatmapLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HeatmapLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = HeatmapLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.heatmapColor = Value<StyleColor>.testConstantValue()
            layer.heatmapIntensity = Value<Double>.testConstantValue()
            layer.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.heatmapOpacity = Value<Double>.testConstantValue()
            layer.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.heatmapRadius = Value<Double>.testConstantValue()
            layer.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.heatmapWeight = Value<Double>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add HeatmapLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: HeatmapLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve HeatmapLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
