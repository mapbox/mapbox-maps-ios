// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

class CircleAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: CircleAnnotationManager?

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyLoadedStyleExpectation = XCTestExpectation(description: "Successfully loaded style to Map")
        successfullyLoadedStyleExpectation.expectedFulfillmentCount = 1
        style.uri = .streets

        didFinishLoadingStyle = { [weak self] _ in

            guard let self = self,
                  let style = try? XCTUnwrap(self.style),
                  let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makeCircleAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

            annotation.circleSortKey =  Double.testConstantValue()
            annotation.circleBlur =  Double.testConstantValue()
            annotation.circleColor =  ColorRepresentable.testConstantValue()
            annotation.circleOpacity =  Double.testConstantValue()
            annotation.circleRadius =  Double.testConstantValue()
            annotation.circleStrokeColor =  ColorRepresentable.testConstantValue()
            annotation.circleStrokeOpacity =  Double.testConstantValue()
            annotation.circleStrokeWidth =  Double.testConstantValue()

            manager.syncAnnotations([annotation])
            self.manager = manager
            successfullyLoadedStyleExpectation.fulfill()
        }

        wait(for: [successfullyLoadedStyleExpectation], timeout: 5.0)
    }

    func testAnnotationPersistence() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        mapView?.mapboxMap.onNext(.mapLoaded, handler: { [weak self] _ in
            guard let self = self,
                let style = try? XCTUnwrap(self.style),
                let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makeCircleAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

            manager.syncAnnotations([annotation])
            self.manager = manager

            do {
             let isPersistent = try style._isPersistentLayer(id: manager.layerId)
             XCTAssertTrue(isPersistent, "The layer with id \(manager.layerId) should be persistent.")
            } catch {
             XCTFail("Unable to verify that the layer with id \(manager.layerId) is persistent.")
            }
        })
    }
}

// End of generated file
// swiftlint:enable all
