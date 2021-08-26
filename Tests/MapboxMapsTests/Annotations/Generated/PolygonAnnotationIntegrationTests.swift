// swiftlint:disable all
// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolygonAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let managerCreatedExpectation = XCTestExpectation(description: "Successfully created annotation manager.")
        style?.uri = .streets
        didFinishLoadingStyle = { _ in
            guard let mapView = self.mapView else {
                return
            }
            self.manager = mapView.annotations.makePolygonAnnotationManager()
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
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))

        annotation.fillOpacity = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer: FillLayer = try? self.style?.layer(withId: self.manager.layerId) else {
                return false
            }
            return layer.fillOpacity == .expression(
                Exp(.number) {
                    Exp(.get) {
                        "fill-opacity"
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
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))

        annotation.fillOpacity = 10

        manager.annotations.append(annotation)

        manager.syncAnnotationsIfNeeded()

        let layer: FillLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))

        XCTAssertEqual(
            layer.fillOpacity,
            .expression(
                Exp(.number) {
                    Exp(.get) {
                        "fill-opacity"
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
