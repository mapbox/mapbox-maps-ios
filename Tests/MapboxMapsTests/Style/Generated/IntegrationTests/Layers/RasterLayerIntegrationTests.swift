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
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added RasterLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved RasterLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = RasterLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)

            layer.rasterBrightnessMax = Value<Double>.testConstantValue()
            layer.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterBrightnessMin = Value<Double>.testConstantValue()
            layer.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterContrast = Value<Double>.testConstantValue()
            layer.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterFadeDuration = Value<Double>.testConstantValue()
            layer.rasterHueRotate = Value<Double>.testConstantValue()
            layer.rasterHueRotateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterOpacity = Value<Double>.testConstantValue()
            layer.rasterOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterResampling = Value<RasterResampling>.testConstantValue()
            layer.rasterSaturation = Value<Double>.testConstantValue()
            layer.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RasterLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as RasterLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file