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
            layer.layout?.visibility = .constant(.visible)

            layer.paint?.fillExtrusionBase = Value<Double>.testConstantValue()
            layer.paint?.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionHeight = Value<Double>.testConstantValue()
            layer.paint?.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionOpacity = Value<Double>.testConstantValue()
            layer.paint?.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.fillExtrusionPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillExtrusionTranslateAnchor = Value<FillExtrusionTranslateAnchor>.testConstantValue()
            layer.paint?.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add FillExtrusionLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id", type: FillExtrusionLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve FillExtrusionLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file