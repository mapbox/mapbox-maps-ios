// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class RasterLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add RasterLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = RasterLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.rasterBrightnessMax = Value<Double>.testConstantValue()
            layer.paint?.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.rasterBrightnessMin = Value<Double>.testConstantValue()
            layer.paint?.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.rasterContrast = Value<Double>.testConstantValue()
            layer.paint?.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.rasterFadeDuration = Value<Double>.testConstantValue()
            layer.paint?.rasterHueRotate = Value<Double>.testConstantValue()
            layer.paint?.rasterHueRotateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.rasterOpacity = Value<Double>.testConstantValue()
            layer.paint?.rasterOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.rasterResampling = RasterResampling.testConstantValue()
            layer.paint?.rasterSaturation = Value<Double>.testConstantValue()
            layer.paint?.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add RasterLayer because of error: \(error)")
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