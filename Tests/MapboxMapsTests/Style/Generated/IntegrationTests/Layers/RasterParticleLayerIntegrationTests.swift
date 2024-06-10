// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterParticleLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added RasterParticleLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved RasterParticleLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = RasterParticleLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.rasterParticleArrayBand = Value<String>.testConstantValue()
            layer.rasterParticleColor = Value<StyleColor>.testConstantValue()
            layer.rasterParticleCount = Value<Double>.testConstantValue()
            layer.rasterParticleFadeOpacityFactor = Value<Double>.testConstantValue()
            layer.rasterParticleFadeOpacityFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.rasterParticleMaxSpeed = Value<Double>.testConstantValue()
            layer.rasterParticleResetRateFactor = Value<Double>.testConstantValue()
            layer.rasterParticleSpeedFactor = Value<Double>.testConstantValue()
            layer.rasterParticleSpeedFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RasterParticleLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: RasterParticleLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterParticleLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
