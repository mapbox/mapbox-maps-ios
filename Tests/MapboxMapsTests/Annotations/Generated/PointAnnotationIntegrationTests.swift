// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

class PointAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PointAnnotationManager?

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyLoadedStyleExpectation = XCTestExpectation(description: "Successfully loaded style to Map")
        successfullyLoadedStyleExpectation.expectedFulfillmentCount = 1
        style.uri = .streets

        didFinishLoadingStyle = { [weak self] _ in

            guard let self = self,
                  let style = try? XCTUnwrap(self.style),
                  let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makePointAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

            annotation.iconAnchor =  IconAnchor.testConstantValue()
            annotation.iconImage =  String.testConstantValue()
            annotation.iconOffset =  [Double].testConstantValue()
            annotation.iconRotate =  Double.testConstantValue()
            annotation.iconSize =  Double.testConstantValue()
            annotation.symbolSortKey =  Double.testConstantValue()
            annotation.textAnchor =  TextAnchor.testConstantValue()
            annotation.textField =  String.testConstantValue()
            annotation.textJustify =  TextJustify.testConstantValue()
            annotation.textLetterSpacing =  Double.testConstantValue()
            annotation.textMaxWidth =  Double.testConstantValue()
            annotation.textOffset =  [Double].testConstantValue()
            annotation.textRadialOffset =  Double.testConstantValue()
            annotation.textRotate =  Double.testConstantValue()
            annotation.textSize =  Double.testConstantValue()
            annotation.textTransform =  TextTransform.testConstantValue()
            annotation.iconColor =  ColorRepresentable.testConstantValue()
            annotation.iconHaloBlur =  Double.testConstantValue()
            annotation.iconHaloColor =  ColorRepresentable.testConstantValue()
            annotation.iconHaloWidth =  Double.testConstantValue()
            annotation.iconOpacity =  Double.testConstantValue()
            annotation.textColor =  ColorRepresentable.testConstantValue()
            annotation.textHaloBlur =  Double.testConstantValue()
            annotation.textHaloColor =  ColorRepresentable.testConstantValue()
            annotation.textHaloWidth =  Double.testConstantValue()
            annotation.textOpacity =  Double.testConstantValue()

            manager.annotations = [annotation]
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

            let manager = mapView.annotations.makePointAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

            manager.annotations = [annotation]
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
