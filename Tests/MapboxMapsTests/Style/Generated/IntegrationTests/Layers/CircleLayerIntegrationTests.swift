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
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added CircleLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved CircleLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = CircleLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)
            layer.layout?.circleSortKey = Value<Double>.testConstantValue()

            layer.paint?.circleBlur = Value<Double>.testConstantValue()
            layer.paint?.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleOpacity = Value<Double>.testConstantValue()
            layer.paint?.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circlePitchAlignment = Value<CirclePitchAlignment>.testConstantValue()
            layer.paint?.circlePitchScale = Value<CirclePitchScale>.testConstantValue()
            layer.paint?.circleRadius = Value<Double>.testConstantValue()
            layer.paint?.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeOpacity = Value<Double>.testConstantValue()
            layer.paint?.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleStrokeWidth = Value<Double>.testConstantValue()
            layer.paint?.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.circleTranslateAnchor = Value<CircleTranslateAnchor>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add CircleLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as CircleLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve CircleLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file