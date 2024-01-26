@available(iOS 13.0, *)
final class LayerAnnotationCoordinator {

    private struct DisplayedAnnotationGroup {
        var positionalId: AnyHashable
        var stringId: String
        // Maps stable id to string ID for every annotation
        var idsMap: [AnyHashable: String] = [:]
    }

    private let annotationOrchestrator: AnnotationOrchestrator
    private var displayedAnnotationGroups = [DisplayedAnnotationGroup]()

    init(annotationOrchestrator: AnnotationOrchestrator) {
        self.annotationOrchestrator = annotationOrchestrator
    }

    func update(annotations newAnnotations: [AnnotationGroup]) {
        let displayedIds = displayedAnnotationGroups.map(\.positionalId)
        let newIds = newAnnotations.map(\.positionalId)

        let diff = newIds.diff(from: displayedIds, id: \.self)

        var oldIdTable = Dictionary(uniqueKeysWithValues: displayedAnnotationGroups.map { ($0.positionalId, $0) })
        for removeId in diff.remove {
            guard let stringId = oldIdTable.removeValue(forKey: removeId)?.stringId else { continue }
            annotationOrchestrator.removeAnnotationManager(withId: stringId)
        }

        self.displayedAnnotationGroups = newAnnotations.map { group in
            let layerId = group.layerId ?? String(UUID().uuidString.prefix(5))
            let positionalId = group.positionalId
            var displayedGroup = oldIdTable[positionalId] ?? DisplayedAnnotationGroup(positionalId: positionalId, stringId: layerId)
            group.update(self.annotationOrchestrator, displayedGroup.stringId, &displayedGroup.idsMap)
            return displayedGroup
        }
    }
}
