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
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Successfully add LineLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = LineLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible
            layer.layout?.lineCap = LineCap.testConstantValue()
            layer.layout?.lineJoin = LineJoin.testConstantValue()
            layer.layout?.lineMiterLimit = Value<Double>.testConstantValue()
            layer.layout?.lineRoundLimit = Value<Double>.testConstantValue()
            layer.layout?.lineSortKey = Value<Double>.testConstantValue()

            layer.paint?.lineBlur = Value<Double>.testConstantValue()
            layer.paint?.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineDasharray = Value<[Double]>.testConstantValue()
            layer.paint?.lineDasharrayTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineGapWidth = Value<Double>.testConstantValue()
            layer.paint?.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineGradient = Value<String>.testConstantValue()
            layer.paint?.lineOffset = Value<Double>.testConstantValue()
            layer.paint?.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineOpacity = Value<Double>.testConstantValue()
            layer.paint?.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.linePattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.linePatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineTranslate = Value<[Double]>.testConstantValue()
            layer.paint?.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.lineTranslateAnchor = LineTranslateAnchor.testConstantValue()
            layer.paint?.lineWidth = Value<Double>.testConstantValue()
            layer.paint?.lineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add LineLayer because of error: \(error)")
            }
        }

//         didBecomeIdle = { _ in

// //            if let snapshot = mapView.snapshot() {
// //                let attachment = XCTAttachment(image: snapshot)
// //                self.add(attachment)
// //
// //                // TODO: Compare images...
// //                //
// //            }

//             expectation.fulfill()
//         }

        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file