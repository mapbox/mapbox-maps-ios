@available(iOS 13.0, *)
class LayerAnnotationCoordinator {

    private struct DisplayedAnnotationGroup {
        var id: AnyHashable
        var stringId: String = String(UUID().uuidString.prefix(5))
        // Maps stable id to string ID for every annotation
        var idsMap: [AnyHashable: String] = [:]
    }

    private let annotationOrchestrator: AnnotationOrchestrator
    private var annotations = [DisplayedAnnotationGroup]()

    init(annotationOrchestrator: AnnotationOrchestrator) {
        self.annotationOrchestrator = annotationOrchestrator
    }

    func update(annotations newAnnotations: [(AnyHashable, AnyAnnotationGroup)]) {
        var oldIdTable = Dictionary(uniqueKeysWithValues: annotations.map { ($0.id, $0) })

        // TODO: keep layers ordering.
        let resultAnnotations = newAnnotations.map { id, group in
            var displayedGroup = oldIdTable.removeValue(forKey: id) ?? DisplayedAnnotationGroup(id: id)
            group.update(self.annotationOrchestrator, displayedGroup.stringId, &displayedGroup.idsMap)
            return displayedGroup
        }

        // Remove the annotations groups, no longer displayed
        for s in oldIdTable.values {
            self.annotationOrchestrator.removeAnnotationManager(withId: s.stringId)
        }

        self.annotations = resultAnnotations

    }
}
