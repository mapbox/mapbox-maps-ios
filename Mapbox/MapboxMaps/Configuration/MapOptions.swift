import Foundation
import MapboxCoreMaps
import MapboxMapsGestures
import MapboxMapsFoundation
import MapboxMapsLocation


/// Options for frame rate
public enum PreferredFramesPerSecond: Int, Equatable {
    /// The default frame rate. This can be either 30 FPS or 60 FPS, depending on
    /// device capabilities.
    case normal = -1

    /// A conservative frame rate; typically 30 FPS.
    case lowPower = 30

    /// The maximum supported frame rate; typically 60 FPS.
    case maximum = 0
}

/// `MapOptions` is the structure used to configure the map with a set of capabilities
public struct MapOptions: Equatable {
    public static func == (lhs: MapOptions, rhs: MapOptions) -> Bool {
        return true // TODO: Fix
    }
    
    /// Used to configure the gestures on the map
    public var gestures: GestureOptions = GestureOptions()

    /// Used to configure the ornaments on the map
    public var ornaments: OrnamentOptions = OrnamentOptions()

    /// Used to configure the camera of the map
    public var camera: MapCameraOptions = MapCameraOptions()

    /// Used to configure the location provider
    public var location: LocationOptions = LocationOptions()

    ///  The preferred frame rate at which the map view is rendered.
    ///
    ///  The default value for this property is
    ///  `MGLMapViewPreferredFramesPerSecondDefault`, which will adaptively set the
    ///  preferred frame rate based on the capability of the user’s device to maintain
    ///  a smooth experience.
    ///
    ///  See Also `CADisplayLink.preferredFramesPerSecond`
    public var preferredFramesPerSecond: PreferredFramesPerSecond = .normal

    ///  A Boolean value indicating whether the map should prefetch tiles.
    ///
    ///  When this property is set to `YES`, the map view prefetches tiles designed for
    ///  a low zoom level and displays them until receiving more detailed tiles for the
    ///  current zoom level. The prefetched tiles typically contain simplified versions
    ///  of each shape, improving the map view’s perceived performance.
    ///
    ///  The default value of this property is `YES`.
    public var prefetchesTiles: Bool = true
}
