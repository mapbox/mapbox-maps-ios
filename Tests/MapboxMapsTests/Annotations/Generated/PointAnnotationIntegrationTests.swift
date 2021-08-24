// swiftlint:disable all
// This file is generated
import XCTest
@testable import MapboxMaps

final class PointAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PointAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let managerCreatedExpectation = XCTestExpectation(description: "Successfully created annotation manager.")
        style?.uri = .streets
        didFinishLoadingStyle = { _ in
            guard let mapView = self.mapView else {
                return
            }
            self.manager = mapView.annotations.makePointAnnotationManager()
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
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textSize = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer: SymbolLayer = try? self.style?.layer(withId: self.manager.layerId) else {
                return false
            }
            return layer.textSize == .expression(
                Exp(.number) {
                    Exp(.get) {
                        "text-size"
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
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textSize = 10

        manager.annotations.append(annotation)

        manager.syncAnnotationsIfNeeded()

        let layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))

        XCTAssertEqual(
            layer.textSize,
            .expression(
                Exp(.number) {
                    Exp(.get) {
                        "text-size"
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
