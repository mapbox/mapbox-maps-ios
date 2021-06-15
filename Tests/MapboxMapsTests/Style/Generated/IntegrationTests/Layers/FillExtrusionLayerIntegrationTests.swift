// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FillExtrusionLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added FillExtrusionLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved FillExtrusionLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = FillExtrusionLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)

            layer.fillExtrusionBase = Value<Double>.testConstantValue()
            layer.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionColor = Value<ColorRepresentable>.testConstantValue()
            layer.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionHeight = Value<Double>.testConstantValue()
            layer.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionOpacity = Value<Double>.testConstantValue()
            layer.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
            layer.fillExtrusionPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionTranslateAnchor = Value<FillExtrusionTranslateAnchor>.testConstantValue()
            layer.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add FillExtrusionLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as FillExtrusionLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve FillExtrusionLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
