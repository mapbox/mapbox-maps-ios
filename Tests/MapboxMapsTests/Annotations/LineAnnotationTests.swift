import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
#endif

import XCTest

//swiftlint:disable explicit_acl explicit_top_level_acl
class LineAnnotationTests: XCTestCase {

    var defaultCoordinates: [CLLocationCoordinate2D]!

    override func setUp() {
        defaultCoordinates = [
            CLLocationCoordinate2DMake(45, -122),
            CLLocationCoordinate2DMake(45, -122),
            CLLocationCoordinate2DMake(45, -122),
            CLLocationCoordinate2DMake(45, -122)
        ]
    }

    override func tearDown() {
        defaultCoordinates = nil
    }

    func testPointAnnotationDefaultValues() {
        // Given state from setUp()

        // When
        let annotation = LineAnnotation(coordinates: self.defaultCoordinates)

        // Then
        XCTAssertNotNil(annotation.identifier)
        XCTAssertTrue(annotation.type == .line)
        XCTAssertNil(annotation.title)
        XCTAssertFalse(annotation.isSelected)
        XCTAssertNotNil(annotation.coordinates)
    }

    func testPointAnnotationsHaveUniqueIdentifiers() {
        // Given
        let annotation1 = LineAnnotation(coordinates: self.defaultCoordinates)

        // When
        let annotation2 = LineAnnotation(coordinates: self.defaultCoordinates)

        // Then
        XCTAssertNotEqual(annotation1.identifier, annotation2.identifier)
    }
}
