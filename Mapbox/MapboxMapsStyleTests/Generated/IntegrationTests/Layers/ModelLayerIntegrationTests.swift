// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class ModelLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add ModelLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = ModelLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.modelOpacity = Value<Double>.testConstantValue()
            layer.paint?.modelOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.modelRotation = Value<[Double]>.testConstantValue()
            layer.paint?.modelRotationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.modelScale = Value<[Double]>.testConstantValue()
            layer.paint?.modelTranslation = Value<[Double]>.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add ModelLayer because of error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file