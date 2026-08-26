import SwiftUI
@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class MapViewAnnotationTests: XCTestCase {
    func testDraggableInitStoresCoordinateBindingAndCallback() {
        var coordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        let binding = Binding(get: { coordinate }, set: { coordinate = $0 })
        var draggingChanges = [Bool]()

        let mapViewAnnotation = MapViewAnnotation(
            coordinate: binding,
            content: { Text("") },
            onDraggingChanged: { draggingChanges.append($0) }
        )

        XCTAssertEqual(mapViewAnnotation.dragCoordinate?.wrappedValue, coordinate)

        mapViewAnnotation.dragCoordinate?.wrappedValue = CLLocationCoordinate2D(latitude: 3, longitude: 4)
        XCTAssertEqual(coordinate, CLLocationCoordinate2D(latitude: 3, longitude: 4))

        mapViewAnnotation.actions.onDraggingChanged?(true)
        XCTAssertEqual(draggingChanges, [true])
    }

    func testNonDraggableInitLeavesDragCoordinateNil() {
        let mapViewAnnotation = MapViewAnnotation(coordinate: .init(latitude: 1, longitude: 2), content: { Text("") })

        XCTAssertNil(mapViewAnnotation.dragCoordinate)
        XCTAssertNil(mapViewAnnotation.actions.onDraggingChanged)
    }
}
