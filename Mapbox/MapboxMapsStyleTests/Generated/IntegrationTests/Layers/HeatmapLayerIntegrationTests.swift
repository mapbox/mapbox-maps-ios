// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class HeatmapLayerIntegrationTests: MapViewIntegrationTestCase {

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

        let expectation = XCTestExpectation(description: "Successfully add HeatmapLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = HeatmapLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible

            layer.paint?.heatmapColor = Value<String>.testConstantValue()
            layer.paint?.heatmapIntensity = Value<Double>.testConstantValue()
            layer.paint?.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapOpacity = Value<Double>.testConstantValue()
            layer.paint?.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapRadius = Value<Double>.testConstantValue()
            layer.paint?.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.heatmapWeight = Value<Double>.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add HeatmapLayer because of error: \(error)")
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