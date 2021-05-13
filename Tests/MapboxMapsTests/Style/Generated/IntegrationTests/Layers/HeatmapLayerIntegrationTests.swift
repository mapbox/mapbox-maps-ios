// This file is generated
import XCTest
@testable import MapboxMaps

class HeatmapLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HeatmapLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HeatmapLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = HeatmapLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)

            layer.paint?.heatmapColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.heatmapIntensity = Value<Double>.testConstantValue()
            layer.paint?.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapOpacity = Value<Double>.testConstantValue()
            layer.paint?.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapRadius = Value<Double>.testConstantValue()
            layer.paint?.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapWeight = Value<Double>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add HeatmapLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as HeatmapLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve HeatmapLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
