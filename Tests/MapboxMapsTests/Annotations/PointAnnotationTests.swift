import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
#endif

import XCTest

//swiftlint:disable explicit_acl explicit_top_level_acl
class PointAnnotationTests: XCTestCase {

    var defaultCoordinate: CLLocationCoordinate2D!

    override func setUp() {
        defaultCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    override func tearDown() {
        defaultCoordinate = nil
    }

    func testPointAnnotationDefaultValues() {
        // Given state from setUp()

        // When
        let annotation = PointAnnotation(coordinate: defaultCoordinate)

        // Then
        XCTAssertNotNil(annotation.identifier)
        XCTAssertTrue(annotation.type == .point)
        XCTAssertNil(annotation.title)
        XCTAssertFalse(annotation.isSelected)
        XCTAssertFalse(annotation.isDraggable)
        XCTAssertNil(annotation.image)
        XCTAssertNotNil(annotation.coordinate)
    }

    func testPointAnnotationsHaveUniqueIdentifiers() {
        // Given
        let annotation1 = PointAnnotation(coordinate: defaultCoordinate)

        // When
        let annotation2 = PointAnnotation(coordinate: defaultCoordinate)

        // Then
        XCTAssertNotEqual(annotation1.identifier, annotation2.identifier)
    }

    func testUpdatingPointAnnotationImageProperty() {
        // Given
        var annotation = PointAnnotation(coordinate: defaultCoordinate)
        let initialAnnotationImage = annotation.image

        // When
        annotation.image = UIImage.squareImage(with: UIColor.yellow,
                                               size: CGSize(width: 100, height: 100))

        // Then
        XCTAssertNotEqual(initialAnnotationImage, annotation.image)
    }
}
