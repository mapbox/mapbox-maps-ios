@available(iOS 13.0, *)
class LayerAnnotationCoordinator {

    private struct DisplayedAnnotationGroup {
        var id: AnyHashable
        var stringId: String
        // Maps stable id to string ID for every annotation
        var idsMap: [AnyHashable: String] = [:]
    }

    private let annotationOrchestrator: AnnotationOrchestrator
    private var annotations = [DisplayedAnnotationGroup]()

    init(annotationOrchestrator: AnnotationOrchestrator) {
        self.annotationOrchestrator = annotationOrchestrator
    }

    func update(annotations newAnnotations: [(AnyHashable, AnnotationGroup)]) {
        let displayedIds = annotations.map(\.id)
        let newIds = newAnnotations.map(\.0)

        let diff = newIds.diff(from: displayedIds, id: { $0 })

        var oldIdTable = Dictionary(uniqueKeysWithValues: annotations.map { ($0.id, $0) })
        for removeId in diff.remove {
            guard let stringId = oldIdTable.removeValue(forKey: removeId)?.stringId else { continue }
            annotationOrchestrator.removeAnnotationManager(withId: stringId)
        }

        self.annotations = newAnnotations.map { id, group in
            let layerId = group.layerId ?? String(UUID().uuidString.prefix(5))
            var displayedGroup = oldIdTable[id] ?? DisplayedAnnotationGroup(id: id, stringId: layerId)
            group.update(self.annotationOrchestrator, displayedGroup.stringId, &displayedGroup.idsMap)
            return displayedGroup
        }
    }
}
