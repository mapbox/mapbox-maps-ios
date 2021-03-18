import Foundation

/// `MapOptions` is the structure used to configure the map with a set of capabilities
public struct MapOptions: Equatable {
    /// Used to configure the gestures on the map
    public var gestures: GestureOptions = GestureOptions()

    /// Used to configure the ornaments on the map
    public var ornaments: OrnamentOptions = OrnamentOptions()

    /// Used to configure the camera of the map
    public var camera: MapCameraOptions = MapCameraOptions()

    /// Used to configure the location provider
    public var location: LocationOptions = LocationOptions()

    public var render: RenderOptions = RenderOptions()

    public var annotations: AnnotationOptions = AnnotationOptions()
}
