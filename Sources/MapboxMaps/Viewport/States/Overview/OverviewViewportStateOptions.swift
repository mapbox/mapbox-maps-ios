import Turf
import CoreLocation

@_spi(Experimental) public struct OverviewViewportStateOptions: Equatable {
    public var geometry: Geometry
    public var padding: UIEdgeInsets
    public var bearing: CLLocationDirection?
    public var pitch: CGFloat?
    public var animationDuration: TimeInterval

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
