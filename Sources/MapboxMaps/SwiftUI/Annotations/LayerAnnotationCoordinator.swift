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
        let displayedIds = annotations.map(\.id)
        let newIds = newAnnotations.map(\.0)

        let diff = newIds.diff(from: displayedIds, id: { $0 })

        var oldIdTable = Dictionary(uniqueKeysWithValues: annotations.map { ($0.id, $0) })
        for removeId in diff.remove {
            guard let stringId = oldIdTable.removeValue(forKey: removeId)?.stringId else { continue }
            annotationOrchestrator.removeAnnotationManager(withId: stringId)
        }

        self.annotations = newAnnotations.map { id, group in
            var displayedGroup = oldIdTable[id] ?? DisplayedAnnotationGroup(id: id)
            group.update(self.annotationOrchestrator, displayedGroup.stringId, &displayedGroup.idsMap)
            return displayedGroup
        }
    }
}
