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
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added LineLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved LineLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = LineLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)
            layer.layout?.lineCap = Value<LineCap>.testConstantValue()
            layer.layout?.lineJoin = Value<LineJoin>.testConstantValue()
            layer.layout?.lineMiterLimit = Value<Double>.testConstantValue()
            layer.layout?.lineRoundLimit = Value<Double>.testConstantValue()
            layer.layout?.lineSortKey = Value<Double>.testConstantValue()

            layer.paint?.lineBlur = Value<Double>.testConstantValue()
            layer.paint?.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineDasharrayTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineGapWidth = Value<Double>.testConstantValue()
            layer.paint?.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineGradient = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.lineOffset = Value<Double>.testConstantValue()
            layer.paint?.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineOpacity = Value<Double>.testConstantValue()
            layer.paint?.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.linePattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.linePatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineTranslateAnchor = Value<LineTranslateAnchor>.testConstantValue()
            layer.paint?.lineWidth = Value<Double>.testConstantValue()
            layer.paint?.lineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add LineLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: LineLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive LineLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file