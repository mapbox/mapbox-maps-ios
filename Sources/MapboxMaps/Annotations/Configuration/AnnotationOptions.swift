import Foundation

/// :nodoc:
public struct AnnotationSourceOptions: Equatable {
    // TODO: Add source and cluster options
}

/// Configuration options for the AnnotationManager
public struct AnnotationOptions: Equatable {
    /// The `LayerPosition` used to position the underlying style layers. Default will position the
    /// layers above existing layers.
    public var layerPosition: LayerPosition?

    // TODO: Handle multiple layer Ids
//    /// The layer identifier for the layer used by the AnnotationManager. Default is nil, meaning a
//    /// default identifier will be used.
//    public var layerId: String? = nil

    /// The source identifier for the layer used by the AnnotationManager. Default is nil, meaning a
    /// default identifier will be used.
    public var sourceId: String?

    /// :nodoc: Source configuration options
    public var sourceOptions: AnnotationSourceOptions = AnnotationSourceOptions()
}
