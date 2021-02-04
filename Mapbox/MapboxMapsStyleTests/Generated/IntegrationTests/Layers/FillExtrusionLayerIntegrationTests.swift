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
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Successfully add FillExtrusionLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = FillExtrusionLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

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
            layer.paint?.fillExtrusionTranslateAnchor = FillExtrusionTranslateAnchor.testConstantValue()
            layer.paint?.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add FillExtrusionLayer because of error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file