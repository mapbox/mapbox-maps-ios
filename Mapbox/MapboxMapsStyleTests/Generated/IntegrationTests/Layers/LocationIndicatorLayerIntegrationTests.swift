// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class LocationIndicatorLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add LocationIndicatorLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = LocationIndicatorLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible
            layer.layout?.bearingImage = Value<ResolvedImage>.testConstantValue()
            layer.layout?.shadowImage = Value<ResolvedImage>.testConstantValue()
            layer.layout?.topImage = Value<ResolvedImage>.testConstantValue()

            layer.paint?.accuracyRadius = Value<Double>.testConstantValue()
            layer.paint?.accuracyRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.accuracyRadiusBorderColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.accuracyRadiusBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.accuracyRadiusColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.bearing = Value<Double>.testConstantValue()
            layer.paint?.bearingImageSize = Value<Double>.testConstantValue()
            layer.paint?.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.emphasisCircleColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.emphasisCircleRadius = Value<Double>.testConstantValue()
            layer.paint?.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.imagePitchDisplacement = Value<Double>.testConstantValue()
            layer.paint?.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.perspectiveCompensation = Value<Double>.testConstantValue()
            layer.paint?.shadowImageSize = Value<Double>.testConstantValue()
            layer.paint?.shadowImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.topImageSize = Value<Double>.testConstantValue()
            layer.paint?.topImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add LocationIndicatorLayer because of error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file