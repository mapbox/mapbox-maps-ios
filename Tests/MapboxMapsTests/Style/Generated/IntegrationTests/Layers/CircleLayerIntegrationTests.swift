// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added CircleLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved CircleLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = CircleLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.circleSortKey = Value<Double>.testConstantValue()
            layer.circleBlur = Value<Double>.testConstantValue()
            layer.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleColor = Value<StyleColor>.testConstantValue()
            layer.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleEmissiveStrength = Value<Double>.testConstantValue()
            layer.circleEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleOpacity = Value<Double>.testConstantValue()
            layer.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circlePitchAlignment = Value<CirclePitchAlignment>.testConstantValue()
            layer.circlePitchScale = Value<CirclePitchScale>.testConstantValue()
            layer.circleRadius = Value<Double>.testConstantValue()
            layer.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleStrokeColor = Value<StyleColor>.testConstantValue()
            layer.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleStrokeOpacity = Value<Double>.testConstantValue()
            layer.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleStrokeWidth = Value<Double>.testConstantValue()
            layer.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.circleTranslateAnchor = Value<CircleTranslateAnchor>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add CircleLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: CircleLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve CircleLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
