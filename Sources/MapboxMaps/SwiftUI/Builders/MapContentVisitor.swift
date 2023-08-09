import SwiftUI

/// :nodoc:
@_spi(Experimental)
public protocol _MapContentVisitor: AnyObject {
    /// :nodoc:
    func push(_ idPart: AnyHashable)

    /// :nodoc:
    func pop()

    /// :nodoc:
    func add(viewAnnotation: ViewAnnotation)

    /// :nodoc:
    var locationOptions: LocationOptions { get set }
}

final class DefaultMapContentVisitor: _MapContentVisitor {
    var locationOptions: LocationOptions = LocationOptions()

    private var id: [AnyHashable] = []
    private(set) var visitedViewAnnotations: [[AnyHashable]: ViewAnnotation] = [:]

    func push(_ idPart: AnyHashable) {
        id.append(idPart)
    }

    func pop() {
        id.removeLast()
    }

    func add(viewAnnotation: ViewAnnotation) {
        visitedViewAnnotations[id] = viewAnnotation
    }

}
