import os.log

@available(iOS 13.0, *)
struct MountedAnnotationGroup<M: MapContentAnnotationManager>: MapContentMountedComponent {
    private let annotations: [(AnyHashable, M.AnnotationType)]
    private let layerId: String
    private let clusterOptions: ClusterOptions?
    private let updateProperties: (M) -> Void

    init(
        layerId: String,
        clusterOptions: ClusterOptions?,
        annotations: [(AnyHashable, M.AnnotationType)],
        updateProperties: @escaping (M) -> Void
    ) {
        self.layerId = layerId
        self.clusterOptions = clusterOptions
        self.annotations = annotations
        self.updateProperties = updateProperties
    }

    func mount(with context: MapContentNodeContext) throws {
        guard let orchestrator = context.content?.layerAnnotations.value else {
            return
        }

        os_log(.debug, log: .contentDSL, "Annotation add %s", layerId)

        let manager = M.make(
            layerId: layerId,
            layerPosition: context.resolveLayerPosition(),
            clusterOptions: clusterOptions,
            using: orchestrator
        )
        manager.isSwiftUI = true
        updateProperties(manager)
        manager.set(newAnnotations: annotations)
    }

    func unmount(with context: MapContentNodeContext) throws {
        os_log(.debug, log: .contentDSL, "Annotation remove %s", layerId)
        let annotationOrchestrator = context.content?.layerAnnotations.value
        annotationOrchestrator?.removeAnnotationManager(withId: layerId)
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        guard let old = old as? Self, old.layerId == layerId else {
            return false
        }

        guard let orchestrator = context.content?.layerAnnotations.value,
              let manager = orchestrator.annotationManagersById[layerId] as? M else {
            return false
        }

        os_log(.debug, log: .contentDSL, "Annotation update %s", layerId)

        manager.isSwiftUI = true
        updateProperties(manager)
        manager.layerPosition = context.resolveLayerPosition()
        manager.set(newAnnotations: annotations)

        return true
    }

    func updateMetadata(with context: MapContentNodeContext) {
        context.lastLayerId = layerId
    }
}
