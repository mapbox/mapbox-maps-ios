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
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added RasterLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved RasterLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in

            var layer = RasterLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)

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
            layer.paint?.rasterResampling = Value<RasterResampling>.testConstantValue()
            layer.paint?.rasterSaturation = Value<Double>.testConstantValue()
            layer.paint?.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add RasterLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: RasterLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive RasterLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file