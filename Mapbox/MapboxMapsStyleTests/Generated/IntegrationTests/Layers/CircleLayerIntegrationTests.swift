// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class CircleLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added CircleLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved CircleLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = CircleLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible
            layer.layout?.circleSortKey = Value<Double>.testConstantValue()

            layer.paint?.circleBlur = Value<Double>.testConstantValue()
            layer.paint?.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleOpacity = Value<Double>.testConstantValue()
            layer.paint?.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circlePitchAlignment = CirclePitchAlignment.testConstantValue()
            layer.paint?.circlePitchScale = CirclePitchScale.testConstantValue()
            layer.paint?.circleRadius = Value<Double>.testConstantValue()
            layer.paint?.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeOpacity = Value<Double>.testConstantValue()
            layer.paint?.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeWidth = Value<Double>.testConstantValue()
            layer.paint?.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleTranslateAnchor = CircleTranslateAnchor.testConstantValue()

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add CircleLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: CircleLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive CircleLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file