import SwiftUI

/// :nodoc:
@_spi(Experimental)
public protocol _MapContentVisitor {
    /// :nodoc:
    func push(_ idPart: AnyHashable)

    /// :nodoc:
    func pop()

    /// :nodoc:
    func add(viewAnnotation: ViewAnnotation)
}

final class DefaultMapContentVisitor: _MapContentVisitor {
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
