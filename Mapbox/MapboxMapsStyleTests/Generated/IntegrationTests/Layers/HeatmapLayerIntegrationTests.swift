// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class HeatmapLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HeatmapLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HeatmapLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = HeatmapLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.heatmapColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.heatmapIntensity = Value<Double>.testConstantValue()
            layer.paint?.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapOpacity = Value<Double>.testConstantValue()
            layer.paint?.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapRadius = Value<Double>.testConstantValue()
            layer.paint?.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapWeight = Value<Double>.testConstantValue()

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add HeatmapLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: HeatmapLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive HeatmapLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file