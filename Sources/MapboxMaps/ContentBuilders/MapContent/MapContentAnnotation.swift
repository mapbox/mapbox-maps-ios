protocol MapContentAnnotation {
    var id: String { get set }
    var isDraggable: Bool { get set  }
    var isSelected: Bool { get set }
}

protocol MapContentAnnotationManager: AnyObject {
    associatedtype AnnotationType: MapContentAnnotation
    var layerPosition: LayerPosition? { get set }
    var isSwiftUI: Bool { get set }

    func set(newAnnotations: [(AnyHashable, AnnotationType)])

    static func make(
        layerId: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?,
        using orchestrator: AnnotationOrchestrator
    ) -> Self
}
