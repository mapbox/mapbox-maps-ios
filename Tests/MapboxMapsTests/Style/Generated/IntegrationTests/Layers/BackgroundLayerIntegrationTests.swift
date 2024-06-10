// This file is generated
import XCTest
@testable import MapboxMaps

final class BackgroundLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added BackgroundLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved BackgroundLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = BackgroundLayer(id: "test-id")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.backgroundColor = Value<StyleColor>.testConstantValue()
            layer.backgroundColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.backgroundEmissiveStrength = Value<Double>.testConstantValue()
            layer.backgroundEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.backgroundOpacity = Value<Double>.testConstantValue()
            layer.backgroundOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.backgroundPattern = Value<ResolvedImage>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add BackgroundLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: BackgroundLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve BackgroundLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
