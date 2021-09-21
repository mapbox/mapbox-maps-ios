// This file is generated
import XCTest
@testable import MapboxMaps

final class SkyLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added SkyLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved SkyLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = SkyLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)

            layer.skyAtmosphereColor = Value<StyleColor>.testConstantValue()
            layer.skyAtmosphereHaloColor = Value<StyleColor>.testConstantValue()
            layer.skyAtmosphereSunIntensity = Value<Double>.testConstantValue()
            layer.skyGradient = Value<StyleColor>.testConstantValue()
            layer.skyGradientRadius = Value<Double>.testConstantValue()
            layer.skyOpacity = Value<Double>.testConstantValue()
            layer.skyOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.skyType = Value<SkyType>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add SkyLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id", type: SkyLayer.self) as SkyLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve SkyLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
