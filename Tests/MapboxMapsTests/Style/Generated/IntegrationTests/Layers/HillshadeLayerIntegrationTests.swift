// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class HillshadeLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HillshadeLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HillshadeLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = HillshadeLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)

            layer.paint?.hillshadeAccentColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeAccentColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeExaggeration = Value<Double>.testConstantValue()
            layer.paint?.hillshadeExaggerationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeHighlightColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeHighlightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeIlluminationAnchor = Value<HillshadeIlluminationAnchor>.testConstantValue()
            layer.paint?.hillshadeIlluminationDirection = Value<Double>.testConstantValue()
            layer.paint?.hillshadeShadowColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeShadowColorTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add HillshadeLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: HillshadeLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive HillshadeLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file