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
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HillshadeLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HillshadeLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = HillshadeLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)

            layer.hillshadeAccentColor = Value<ColorRepresentable>.testConstantValue()
            layer.hillshadeAccentColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeExaggeration = Value<Double>.testConstantValue()
            layer.hillshadeExaggerationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeHighlightColor = Value<ColorRepresentable>.testConstantValue()
            layer.hillshadeHighlightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeIlluminationAnchor = Value<HillshadeIlluminationAnchor>.testConstantValue()
            layer.hillshadeIlluminationDirection = Value<Double>.testConstantValue()
            layer.hillshadeShadowColor = Value<ColorRepresentable>.testConstantValue()
            layer.hillshadeShadowColorTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add HillshadeLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id") as HillshadeLayer
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve HillshadeLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
