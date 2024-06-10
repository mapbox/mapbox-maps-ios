// This file is generated
import XCTest
@testable import MapboxMaps

final class LocationIndicatorLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added LocationIndicatorLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved LocationIndicatorLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = LocationIndicatorLayer(id: "test-id")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.bearingImage = Value<ResolvedImage>.testConstantValue()
            layer.shadowImage = Value<ResolvedImage>.testConstantValue()
            layer.topImage = Value<ResolvedImage>.testConstantValue()
            layer.accuracyRadius = Value<Double>.testConstantValue()
            layer.accuracyRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.accuracyRadiusBorderColor = Value<StyleColor>.testConstantValue()
            layer.accuracyRadiusBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.accuracyRadiusColor = Value<StyleColor>.testConstantValue()
            layer.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.bearing = Value<Double>.testConstantValue()
            layer.bearingTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.bearingImageSize = Value<Double>.testConstantValue()
            layer.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.emphasisCircleColor = Value<StyleColor>.testConstantValue()
            layer.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.emphasisCircleRadius = Value<Double>.testConstantValue()
            layer.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.imagePitchDisplacement = Value<Double>.testConstantValue()
            layer.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.locationIndicatorOpacity = Value<Double>.testConstantValue()
            layer.locationIndicatorOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.perspectiveCompensation = Value<Double>.testConstantValue()
            layer.shadowImageSize = Value<Double>.testConstantValue()
            layer.shadowImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.topImageSize = Value<Double>.testConstantValue()
            layer.topImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try mapView.mapboxMap.addPersistentLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add LocationIndicatorLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: LocationIndicatorLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve LocationIndicatorLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
