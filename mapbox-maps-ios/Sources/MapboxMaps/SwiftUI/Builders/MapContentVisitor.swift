import SwiftUI

/// Type erasure wrapper for AnnotationsGroup.
struct AnyAnnotationGroup {
    var update: (AnnotationOrchestrator, String, inout [AnyHashable: String]) -> Void
}

protocol MapContentVisitor: AnyObject {
    var id: [AnyHashable] { get }
    func push(_ idPart: AnyHashable)
    func pop()
    func add(viewAnnotation: ViewAnnotation)
    var locationOptions: LocationOptions { get set }
    func add(annotationGroup: AnyAnnotationGroup)
}

final class DefaultMapContentVisitor: MapContentVisitor {
    var locationOptions: LocationOptions = LocationOptions()

    private(set) var id: [AnyHashable] = []
    private(set) var visitedViewAnnotations: [AnyHashable: ViewAnnotation] = [:]

    private(set) var annotationGroups: [(AnyHashable, AnyAnnotationGroup)] = []

    func push(_ idPart: AnyHashable) {
        id.append(idPart)
    }

    func pop() {
        id.removeLast()
    }

    func add(viewAnnotation: ViewAnnotation) {
        visitedViewAnnotations[id] = viewAnnotation
    }

    func add(annotationGroup: AnyAnnotationGroup) {
        annotationGroups.append((id, annotationGroup))
    }
}
