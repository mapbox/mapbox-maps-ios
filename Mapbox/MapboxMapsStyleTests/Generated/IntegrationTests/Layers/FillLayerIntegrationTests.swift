// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FillLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add FillLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = FillLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible
            layer.layout?.fillSortKey = Value<Double>.testConstantValue()

            layer.paint?.fillAntialias = Value<Bool>.testConstantValue()
            layer.paint?.fillColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillOpacity = Value<Double>.testConstantValue()
            layer.paint?.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillOutlineColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillPattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.fillPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillTranslate = Value<[Double]>.testConstantValue()
            layer.paint?.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillTranslateAnchor = FillTranslateAnchor.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add FillLayer because of error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file