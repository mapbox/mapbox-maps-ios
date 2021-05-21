import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
#endif

import XCTest

//swiftlint:disable explicit_acl explicit_top_level_acl
class PolygonAnnotationTests: XCTestCase {

    var defaultCoordinates: [CLLocationCoordinate2D]!

    override func setUp() {
        defaultCoordinates = [
            CLLocationCoordinate2DMake(24, -89),
            CLLocationCoordinate2DMake(24, -88),
            CLLocationCoordinate2DMake(26, -88),
            CLLocationCoordinate2DMake(26, -89),
            CLLocationCoordinate2DMake(24, -89)
        ]
    }

    override func tearDown() {
        defaultCoordinates = nil
    }

    func testPolygonAnnotationDefaultValues() {
        // Given state from setUp()

        // When
        let annotation = PolygonAnnotation_Legacy(coordinates: defaultCoordinates)

        // Then
        XCTAssertNotNil(annotation.identifier)
        XCTAssertTrue(annotation.type == .polygon)
        XCTAssertNil(annotation.title)
        XCTAssertFalse(annotation.isSelected)
        XCTAssertNotNil(annotation.coordinates)
    }

    func testPolygonAnnotationsHaveUniqueIdentifiers() {
        // Given
        let annotation1 = PolygonAnnotation_Legacy(coordinates: defaultCoordinates)

        // When
        let annotation2 = PolygonAnnotation_Legacy(coordinates: defaultCoordinates)

        // Then
        XCTAssertNotEqual(annotation1.identifier, annotation2.identifier)
    }

    func testPolygonWithHoles() {

        let interiorPolygon = [
            CLLocationCoordinate2DMake(24.806681, -88.637695),
            CLLocationCoordinate2DMake(24.806681, -88.308105),
            CLLocationCoordinate2DMake(25.224820, -88.308105),
            CLLocationCoordinate2DMake(25.224820, -88.637695),
            CLLocationCoordinate2DMake(24.806681, -88.637695)
        ]

        let polygon = PolygonAnnotation_Legacy(coordinates: defaultCoordinates, interiorPolygons: [interiorPolygon])

        XCTAssertNotNil(polygon.interiorPolygons)
    }
}
