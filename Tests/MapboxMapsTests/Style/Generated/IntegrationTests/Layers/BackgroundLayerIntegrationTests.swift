// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class BackgroundLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added BackgroundLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved BackgroundLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in
print("hello")
            var layer = BackgroundLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)

            layer.paint?.backgroundColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.backgroundColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.backgroundOpacity = Value<Double>.testConstantValue()
            layer.paint?.backgroundOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.backgroundPattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.backgroundPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add BackgroundLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: BackgroundLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive BackgroundLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
