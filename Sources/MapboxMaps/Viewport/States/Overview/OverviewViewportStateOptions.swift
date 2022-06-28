import Turf
import CoreLocation

/// Configuration options for ``OverviewViewportState``.
public struct OverviewViewportStateOptions: Equatable {

    /// The geometry that the ``OverviewViewportState`` should use when calculating its camera.
    public var geometry: Geometry

    /// The padding that ``OverviewViewportState`` should use when calculating its camera.
    public var padding: UIEdgeInsets

    /// The bearing that ``OverviewViewportState`` should use when calcualting its camera.
    public var bearing: CLLocationDirection?

    /// The pitch that ``OverviewViewportState`` should use when calculating its camera.
    public var pitch: CGFloat?

    /// The length of the animation performed by ``OverviewViewportState`` when it starts updating
    /// the camera and any time ``OverviewViewportState/options`` is set. See
    /// ``OverviewViewportState/options`` for details.
    public var animationDuration: TimeInterval

    /// Memberwise initializer for `OverviewViewportStateOptions`.
    ///
    /// `geometry` is required, but all other parameters have default values.
    ///
    /// - Parameters:
    ///   - geometry: the geometry for which an overview should be shown.
    ///   - padding: Defaults to `UIEdgeInsets.zero`.
    ///   - bearing: Defaults to 0.
    ///   - pitch: Defaults to 0.
    ///   - animationDuration: Defaults to 1.
    public init(geometry: GeometryConvertible,
                padding: UIEdgeInsets = .zero,
                bearing: CLLocationDirection? = 0,
                pitch: CGFloat? = 0,
                animationDuration: TimeInterval = 1) {
        self.geometry = geometry.geometry
        self.padding = padding
        self.bearing = bearing
        self.pitch = pitch
        self.animationDuration = animationDuration
    }
}
