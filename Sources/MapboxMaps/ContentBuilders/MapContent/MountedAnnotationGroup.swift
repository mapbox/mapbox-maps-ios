import os.log

struct MountedAnnotationGroup<Manager: AnnotationManagerInternal>: MapContentMountedComponent {
    private let annotations: [(AnyHashable, Manager.AnnotationType)]
    private let layerId: String
    private let clusterOptions: ClusterOptions?
    private let updateProperties: (Manager) -> Void

    init(
        layerId: String,
        clusterOptions: ClusterOptions?,
        annotations: [(AnyHashable, Manager.AnnotationType)],
        updateProperties: @escaping (Manager) -> Void
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

        let manager: Manager = orchestrator.make(AnnotationManagerParams(id: layerId, layerPosition: context.resolveLayerPosition(), clusterOptions: clusterOptions))

        update(manager: manager, context: context)
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
              let manager = orchestrator.annotationManagersById[layerId] as? Manager else {
            return false
        }

        os_log(.debug, log: .contentDSL, "Annotation update %s", layerId)

        update(manager: manager, context: context)

        return true
    }

    private func update(manager: Manager, context: MapContentNodeContext) {
        manager.impl.isSwiftUI = true
        updateProperties(manager)
        manager.impl.layerPosition = context.resolveLayerPosition()
        manager.impl.set(newAnnotations: annotations)
    }

    func updateMetadata(with context: MapContentNodeContext) {
        context.lastLayerId = layerId
    }
}
