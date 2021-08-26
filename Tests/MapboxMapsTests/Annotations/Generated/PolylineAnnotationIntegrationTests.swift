// swiftlint:disable all
// This file is generated
import XCTest
@testable import MapboxMaps

final class PolylineAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolylineAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let managerCreatedExpectation = XCTestExpectation(description: "Successfully created annotation manager.")
        style?.uri = .streets
        didFinishLoadingStyle = { _ in
            guard let mapView = self.mapView else {
                return
            }
            self.manager = mapView.annotations.makePolylineAnnotationManager()
            managerCreatedExpectation.fulfill()
        }
        continueAfterFailure = false
        wait(for: [managerCreatedExpectation], timeout: 5.0)
        continueAfterFailure = true
    }

    override func tearDownWithError() throws {
        manager = nil
        try super.tearDownWithError()
    }

    internal func testSourceAndLayerSetup() throws {
        let style = try XCTUnwrap(self.style)
        XCTAssertTrue(style.layerExists(withId: manager.layerId))
        XCTAssertTrue(try style._isPersistentLayer(id: manager.layerId),
                      "The layer with id \(manager.layerId) should be persistent.")
        XCTAssertTrue(style.sourceExists(withId: manager.sourceId))
    }

    func testSynchronizesAnnotationsEventually() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))

        annotation.lineWidth = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer: LineLayer = try? self.style?.layer(withId: self.manager.layerId) else {
                return false
            }
            return layer.lineWidth == .expression(
                Exp(.number) {
                    Exp(.get) {
                        "line-width"
                        Exp(.objectExpression) {
                            Exp(.get) {
                                "styles"
                            }
                        }
                    }
                }
            )
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSyncAnnotationsIfNeeded() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))

        annotation.lineWidth = 10

        manager.annotations.append(annotation)

        manager.syncAnnotationsIfNeeded()

        let layer: LineLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))

        XCTAssertEqual(
            layer.lineWidth,
            .expression(
                Exp(.number) {
                    Exp(.get) {
                        "line-width"
                        Exp(.objectExpression) {
                            Exp(.get) {
                                "styles"
                            }
                        }
                    }
                }
            )
        )
    }
}

// End of generated file
// swiftlint:enable all
