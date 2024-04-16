import UIKit
@testable import MapboxMaps

final class MockViewAnnotationsManager: ViewAnnotationsManaging {
    let mapboxMap = MockMapboxMap()
    @TestSignal var displayLink: Signal<Void>
    var superview = UIView()
    var removedAnnotations = [String]()

    let addStub = Stub<ViewAnnotation, Void>()
    func add(_ annotation: ViewAnnotation) {
        addStub.call(with: annotation)
        annotation.bind(.init(superview: superview, mapboxMap: mapboxMap, displayLink: displayLink, onRemove: { [weak self, id = annotation.id] in
            self?.removedAnnotations.append(id)
        }))
    }
}
