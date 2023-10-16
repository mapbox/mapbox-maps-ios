@_spi(Experimental) @testable import MapboxMaps
import CoreLocation
import XCTest
import SwiftUI

@available(iOS 13.0, *)
final class ViewAnnotationCoordinatorTests: XCTestCase {
    var viewAnnotationsManager: MockViewAnnotationsManager!

    override func setUpWithError() throws {
        viewAnnotationsManager = MockViewAnnotationsManager()
    }

    override func tearDownWithError() throws {
        viewAnnotationsManager = nil
    }

    func testUpdateAnnotations() throws {
        var numberOfViewsAdded = 0
        let me = ViewAnnotationCoordinator(
            viewAnnotationsManager: viewAnnotationsManager,
            addViewController: { _ in
                numberOfViewsAdded += 1
            }, removeViewController: { _ in
                numberOfViewsAdded -= 1
            }
        )
        func verifyAnnotationOptions(_ annotation: ViewAnnotation, _ mapViewAnnotation: MapViewAnnotation) {
            XCTAssertEqual(annotation.annotatedFeature, mapViewAnnotation.annotatedFeature)
            XCTAssertEqual(annotation.allowOverlap, mapViewAnnotation.allowOverlap)
            XCTAssertEqual(annotation.visible, mapViewAnnotation.visible)
            XCTAssertEqual(annotation.selected, mapViewAnnotation.selected)
            XCTAssertEqual(annotation.variableAnchors, mapViewAnnotation.variableAnchors)
        }

        let options = (0...4).map { _ in MapViewAnnotation.random() }
        var annotations = [AnyHashable: MapViewAnnotation]()

        // Add 1 annotation
        annotations[0] = options[0]
        me.updateAnnotations(to: annotations)

        XCTAssertEqual(numberOfViewsAdded, 1, "added total 1 annotation view")
        XCTAssertEqual(viewAnnotationsManager.addStub.invocations.count, 1)
        let annotation0 = try XCTUnwrap(viewAnnotationsManager.addStub.invocations.last?.parameters)
        verifyAnnotationOptions(annotation0, options[0])

        // Add 2 annotations
        annotations[1] = options[1]
        annotations[2] = options[2]
        me.updateAnnotations(to: annotations)

        XCTAssertEqual(numberOfViewsAdded, 3, "added total 3 annotation views")
        XCTAssertEqual(viewAnnotationsManager.addStub.invocations.count, 3, "added 3 annotations")
        let annotation1 = viewAnnotationsManager.addStub.invocations[1].parameters
        let annotation2 = viewAnnotationsManager.addStub.invocations[2].parameters

        me.updateAnnotations(to: annotations)

        XCTAssertEqual(numberOfViewsAdded, 3, "no additions")
        XCTAssertEqual(viewAnnotationsManager.addStub.invocations.count, 3, "no additions")

        // Update 1 anotation
        annotations[0] = options[3]
        me.updateAnnotations(to: annotations)

        XCTAssertEqual(numberOfViewsAdded, 3, "updated")
        XCTAssertEqual(viewAnnotationsManager.addStub.invocations.count, 3)
        verifyAnnotationOptions(annotation0, options[3])

        annotations = [0: options[3]]
        me.updateAnnotations(to: annotations)

        XCTAssertEqual(numberOfViewsAdded, 1)
        XCTAssertEqual(Set(viewAnnotationsManager.removedAnnotations), Set([annotation1.id, annotation2.id]))
    }
}

@available(iOS 13.0, *)
extension MapViewAnnotation {
    static func random() -> MapViewAnnotation {
        MapViewAnnotation(coordinate: CLLocationCoordinate2D.random()) {}
            .allowOverlap(.random())
            .variableAnchors([
                ViewAnnotationAnchorConfig(
                    anchor: .center,
                    offsetX: .random(in: 0..<100),
                    offsetY: .random(in: 0..<100))])
    }
}
