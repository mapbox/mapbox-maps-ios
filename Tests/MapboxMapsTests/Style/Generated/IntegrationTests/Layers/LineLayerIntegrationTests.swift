// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class LineLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added LineLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved LineLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = LineLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.lineCap = Value<LineCap>.testConstantValue()
            layer.lineJoin = Value<LineJoin>.testConstantValue()
            layer.lineMiterLimit = Value<Double>.testConstantValue()
            layer.lineRoundLimit = Value<Double>.testConstantValue()
            layer.lineSortKey = Value<Double>.testConstantValue()

            layer.lineBlur = Value<Double>.testConstantValue()
            layer.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineColor = Value<ColorRepresentable>.testConstantValue()
            layer.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineDasharrayTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineGapWidth = Value<Double>.testConstantValue()
            layer.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineGradient = Value<ColorRepresentable>.testConstantValue()
            layer.lineOffset = Value<Double>.testConstantValue()
            layer.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineOpacity = Value<Double>.testConstantValue()
            layer.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.linePattern = Value<ResolvedImage>.testConstantValue()
            layer.linePatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineTranslateAnchor = Value<LineTranslateAnchor>.testConstantValue()
            layer.lineWidth = Value<Double>.testConstantValue()
            layer.lineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add LineLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as LineLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve LineLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 30.0)
    }
}

// End of generated file
