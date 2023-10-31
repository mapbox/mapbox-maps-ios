import SwiftUI

protocol MapContentVisitor: AnyObject {
    var id: [AnyHashable] { get }
    var locationOptions: LocationOptions { get set }
    @available(iOS 13.0, *)
    func add(viewAnnotation: MapViewAnnotation)
    func add(annotationGroup: AnnotationGroup)
    func visit(id: AnyHashable, content: MapContent)
}

@available(iOS 13.0, *)
final class DefaultMapContentVisitor: MapContentVisitor {
    var locationOptions: LocationOptions = LocationOptions()

    private(set) var id: [AnyHashable] = []
    private(set) var visitedViewAnnotations: [AnyHashable: MapViewAnnotation] = [:]

    private(set) var annotationGroups: [(AnyHashable, AnnotationGroup)] = []

    @available(iOS 13.0, *)
    func add(viewAnnotation: MapViewAnnotation) {
        visitedViewAnnotations[id] = viewAnnotation
    }

    func add(annotationGroup: AnnotationGroup) {
        annotationGroups.append((id, annotationGroup))
    }

    func visit(id: AnyHashable, content: MapContent) {
        self.id.append(id)
        content.visit(self)
        self.id.removeLast()
    }
}
