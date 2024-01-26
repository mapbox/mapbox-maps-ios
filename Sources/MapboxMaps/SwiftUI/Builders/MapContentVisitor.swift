import SwiftUI

protocol MapContentVisitor: AnyObject {
    var positionalId: [AnyHashable] { get }

    @available(iOS 13.0, *)
    func add(viewAnnotation: MapViewAnnotation)
    func add(annotationGroup: AnnotationGroup)
    func add(locationOptions: LocationOptions)

    func visit(id: AnyHashable, content: MapContent)
}

@available(iOS 13.0, *)
final class DefaultMapContentVisitor: MapContentVisitor {
    private(set) var locationOptions: LocationOptions = LocationOptions()
    private(set) var visitedViewAnnotations: [AnyHashable: MapViewAnnotation] = [:]
    private(set) var annotationGroups: [AnnotationGroup] = []

    private(set) var positionalId: [AnyHashable] = []

    @available(iOS 13.0, *)
    func add(viewAnnotation: MapViewAnnotation) {
        visitedViewAnnotations[positionalId] = viewAnnotation
    }

    func add(annotationGroup: AnnotationGroup) {
        annotationGroups.append(annotationGroup)
    }

    func add(locationOptions options: LocationOptions) {
        locationOptions = options
    }

    func visit(id: AnyHashable, content: MapContent) {
        positionalId.append(id)
        content.visit(self)
        positionalId.removeLast()
    }
}
