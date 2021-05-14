import Foundation

/// `MapConfig` is the structure used to configure the map with a set of capabilities
public struct MapConfig: Equatable {

    /// Used to configure the camera of the map
    public var camera: MapCameraOptions = MapCameraOptions()

    public var render: RenderOptions = RenderOptions()

    public var annotations: AnnotationOptions = AnnotationOptions()

    public init() {}
}
