// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added RasterLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved RasterLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = RasterLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.rasterArrayBand = Value<String>.testConstantValue()
            layer.rasterBrightnessMax = Value<Double>.testConstantValue()
            layer.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterBrightnessMin = Value<Double>.testConstantValue()
            layer.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterColor = Value<StyleColor>.testConstantValue()
            layer.rasterColorMixTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterColorRangeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterContrast = Value<Double>.testConstantValue()
            layer.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterElevation = Value<Double>.testConstantValue()
            layer.rasterElevationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterEmissiveStrength = Value<Double>.testConstantValue()
            layer.rasterEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
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
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RasterLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: RasterLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
