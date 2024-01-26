protocol MapContentAnnotation {
    var id: String { get set }
    var isDraggable: Bool { get set  }
    var isSelected: Bool { get set }
}

protocol MapContentAnnotationManager: AnyObject {
    associatedtype AnnotationType: MapContentAnnotation
    var annotations: [AnnotationType] { get set }
    var isSwiftUI: Bool { get set }
}

/// Type erasure wrapper for annotation groups.
struct AnnotationGroup {
    var positionalId: AnyHashable
    var layerId: String?
    var update: (AnnotationOrchestrator, String, inout [AnyHashable: String]) -> Void

    init(
        positionalId: AnyHashable,
        layerId: String? = nil,
        update: @escaping (AnnotationOrchestrator, String, inout [AnyHashable: String]) -> Void
    ) {
        self.positionalId = positionalId
        self.layerId = layerId
        self.update = update
    }

    init<M: MapContentAnnotationManager, Data: RandomAccessCollection, ID: Hashable>(
        positionalId: AnyHashable,
        layerId: String?,
        layerPosition: LayerPosition?,
        store: ForEvery<M.AnnotationType, Data, ID>,
        make: @escaping (AnnotationOrchestrator, String, LayerPosition?) -> M,
        updateProperties: @escaping (M) -> Void
    ) {
        self.positionalId = positionalId
        self.layerId = layerId
        // For some reason, the data in the store corrupts under tests in release mode when captured
        // by `update` closure. Copying the data fixes the issue.
        let data = ForEvery(data: store.data, id: store.id, content: store.content)
        self.update = { orchestrator, resolvedId, annotationsIdMap in
            // Creates or updates annotation manager for a given group.
            let existingManager = orchestrator.annotationManagersById[resolvedId] as? M
            let manager = existingManager ?? make(orchestrator, resolvedId, layerPosition)
            manager.isSwiftUI = true
            updateProperties(manager)

            var annotations = [M.AnnotationType]()
            data.forEach { elementId, annotation in
                var annotation = annotation
                let stringId = annotationsIdMap[elementId] ?? annotation.id
                annotationsIdMap[elementId] = stringId
                annotation.id = stringId
                annotation.isDraggable = false
                annotation.isSelected = false
                annotations.append(annotation)
            }

            manager.annotations = annotations
        }
    }
}
