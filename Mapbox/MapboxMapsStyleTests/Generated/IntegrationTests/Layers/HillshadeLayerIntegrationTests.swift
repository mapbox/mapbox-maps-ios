// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class HillshadeLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add HillshadeLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = HillshadeLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.hillshadeAccentColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeAccentColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeExaggeration = Value<Double>.testConstantValue()
            layer.paint?.hillshadeExaggerationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeHighlightColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeHighlightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.hillshadeIlluminationAnchor = HillshadeIlluminationAnchor.testConstantValue()
            layer.paint?.hillshadeIlluminationDirection = Value<Double>.testConstantValue()
            layer.paint?.hillshadeShadowColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.hillshadeShadowColorTransition = StyleTransition(duration: 10.0, delay: 10.0)

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add HillshadeLayer because of error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file