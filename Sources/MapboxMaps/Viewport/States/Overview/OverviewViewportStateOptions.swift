import Turf
import CoreLocation
import UIKit

/// Configuration options for ``OverviewViewportState``.
public struct OverviewViewportStateOptions: Equatable, Sendable {

    /// The geometry that the ``OverviewViewportState`` should use when calculating its camera.
    public var geometry: Geometry

    /// The padding that ``OverviewViewportState`` should add to geometry when calculating fitting camera.
    ///
    /// - Note: This is different from camera padding, see ``OverviewViewportStateOptions/padding``.
    public var geometryPadding: UIEdgeInsets

    /// The bearing that ``OverviewViewportState`` should use when calcualting its camera.
    public var bearing: CLLocationDirection?

    /// The pitch that ``OverviewViewportState`` should use when calculating its camera.
    public var pitch: CGFloat?

    /// Camera padding to set as camera options.
    public var padding: UIEdgeInsets?

    /// The maximum zoom level to allow.
    public var maxZoom: Double?

    /// The center of the given bounds relative to the map's center, measured in points.
    public var offset: CGPoint?

    /// The length of the animation performed by ``OverviewViewportState`` when it starts updating
    /// the camera and any time ``OverviewViewportState/options`` is set. See
    /// ``OverviewViewportState/options`` for details.
    public var animationDuration: TimeInterval

    /// Memberwise initializer for `OverviewViewportStateOptions`.
    ///
    /// `geometry` is required, but all other parameters have default values.
    ///
    /// - Parameters:
    ///   - geometry: The geometry for which an overview should be shown.
    ///   - geometryPadding: The padding to add to geometry when calculating fitting camera.
    ///   - bearing: Camera bearing.
    ///   - pitch: Camera pitch.
    ///   - padding: Camera padding.
    ///   - maxZoom: The maximum zoom level to allow.
    ///   - offset: The center of the given bounds relative to the map's center, measured in points.
    ///   - animationDuration: Defaults to 1.
    public init(geometry: GeometryConvertible,
                geometryPadding: UIEdgeInsets = .zero,
                bearing: CLLocationDirection? = 0,
                pitch: CGFloat? = 0,
                padding: UIEdgeInsets? = nil,
                maxZoom: Double? = nil,
                offset: CGPoint? = nil,
                animationDuration: TimeInterval = 1) {
        self.geometry = geometry.geometry
        self.geometryPadding = geometryPadding
        self.bearing = bearing
        self.pitch = pitch
        self.padding = padding
        self.maxZoom = maxZoom
        self.offset = offset
        self.animationDuration = animationDuration
    }
}
