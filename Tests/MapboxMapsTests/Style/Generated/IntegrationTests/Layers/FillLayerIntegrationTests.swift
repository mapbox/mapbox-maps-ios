// This file is generated
import XCTest
@testable import MapboxMaps

final class FillLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added FillLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved FillLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = FillLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.fillSortKey = Value<Double>.testConstantValue()
            layer.fillAntialias = Value<Bool>.testConstantValue()
            layer.fillColor = Value<StyleColor>.testConstantValue()
            layer.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillEmissiveStrength = Value<Double>.testConstantValue()
            layer.fillEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillOpacity = Value<Double>.testConstantValue()
            layer.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillOutlineColor = Value<StyleColor>.testConstantValue()
            layer.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillPattern = Value<ResolvedImage>.testConstantValue()
            layer.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillTranslateAnchor = Value<FillTranslateAnchor>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add FillLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: FillLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve FillLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
