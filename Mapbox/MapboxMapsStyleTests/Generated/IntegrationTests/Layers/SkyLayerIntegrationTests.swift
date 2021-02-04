// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class SkyLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add SkyLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = SkyLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.skyAtmosphereColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.skyAtmosphereHaloColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.skyAtmosphereSun = Value<[Double]>.testConstantValue()
            layer.paint?.skyAtmosphereSunIntensity = Value<Double>.testConstantValue()
            layer.paint?.skyGradient = Value<String>.testConstantValue()
            layer.paint?.skyGradientCenter = Value<[Double]>.testConstantValue()
            layer.paint?.skyGradientRadius = Value<Double>.testConstantValue()
            layer.paint?.skyOpacity = Value<Double>.testConstantValue()
            layer.paint?.skyOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.skyType = SkyType.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add SkyLayer because of error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file