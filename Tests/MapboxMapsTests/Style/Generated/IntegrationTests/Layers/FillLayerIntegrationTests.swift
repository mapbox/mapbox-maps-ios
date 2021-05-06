// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FillLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added FillLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved FillLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var layer = FillLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)
            layer.layout?.fillSortKey = Value<Double>.testConstantValue()

            layer.paint?.fillAntialias = Value<Bool>.testConstantValue()
            layer.paint?.fillColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillOpacity = Value<Double>.testConstantValue()
            layer.paint?.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillOutlineColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillPattern = Value<ResolvedImage>.testConstantValue()
            layer.paint?.fillPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.fillTranslateAnchor = Value<FillTranslateAnchor>.testConstantValue()

            // Add the layer
            do {
                try style.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add FillLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try style.layer(withId: "test-id", type: FillLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve FillLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file