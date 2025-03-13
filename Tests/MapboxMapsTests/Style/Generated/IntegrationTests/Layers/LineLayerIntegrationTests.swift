// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class LineLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added LineLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved LineLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            var layer = LineLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.lineCap = Value<LineCap>.testConstantValue()
            layer.lineCrossSlope = Value<Double>.testConstantValue()
            layer.lineElevationReference = Value<LineElevationReference>.testConstantValue()
            layer.lineJoin = Value<LineJoin>.testConstantValue()
            layer.lineMiterLimit = Value<Double>.testConstantValue()
            layer.lineRoundLimit = Value<Double>.testConstantValue()
            layer.lineSortKey = Value<Double>.testConstantValue()
            layer.lineWidthUnit = Value<LineWidthUnit>.testConstantValue()
            layer.lineZOffset = Value<Double>.testConstantValue()
            layer.lineBlur = Value<Double>.testConstantValue()
            layer.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineBorderColor = Value<StyleColor>.testConstantValue()
            layer.lineBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineBorderColorUseTheme = .testConstantValue()
            layer.lineBorderWidth = Value<Double>.testConstantValue()
            layer.lineBorderWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineColor = Value<StyleColor>.testConstantValue()
            layer.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineColorUseTheme = .testConstantValue()
            layer.lineDepthOcclusionFactor = Value<Double>.testConstantValue()
            layer.lineDepthOcclusionFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineEmissiveStrength = Value<Double>.testConstantValue()
            layer.lineEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineGapWidth = Value<Double>.testConstantValue()
            layer.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineGradient = Value<StyleColor>.testConstantValue()
            layer.lineGradientUseTheme = .testConstantValue()
            layer.lineOcclusionOpacity = Value<Double>.testConstantValue()
            layer.lineOcclusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineOffset = Value<Double>.testConstantValue()
            layer.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineOpacity = Value<Double>.testConstantValue()
            layer.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.linePattern = Value<ResolvedImage>.testConstantValue()
            layer.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineTranslateAnchor = Value<LineTranslateAnchor>.testConstantValue()
            layer.lineTrimColor = Value<StyleColor>.testConstantValue()
            layer.lineTrimColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.lineTrimColorUseTheme = .testConstantValue()
            layer.lineWidth = Value<Double>.testConstantValue()
            layer.lineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add LineLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: LineLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve LineLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
