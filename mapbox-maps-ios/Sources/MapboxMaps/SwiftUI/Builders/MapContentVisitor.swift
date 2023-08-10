import SwiftUI

protocol MapContentVisitor: AnyObject {
    func push(_ idPart: AnyHashable)
    func pop()
    func add(viewAnnotation: ViewAnnotation)
    var locationOptions: LocationOptions { get set }
}

final class DefaultMapContentVisitor: MapContentVisitor {
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
