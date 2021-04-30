import Foundation

/// `MapConfig` is the structure used to configure the map with a set of capabilities
public struct MapConfig: Equatable {
    /// Used to configure the gestures on the map
    public var gestures: GestureOptions = GestureOptions()

    /// Used to configure the camera of the map
    public var camera: MapCameraOptions = MapCameraOptions()

    /// Used to configure the location provider
    public var location: LocationOptions = LocationOptions()

    public var render: RenderOptions = RenderOptions()

    public var annotations: AnnotationOptions = AnnotationOptions()

    public init() {}
}
