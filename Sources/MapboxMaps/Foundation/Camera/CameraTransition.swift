import UIKit
import CoreLocation

/// Structure used to represent a desired change to the map's camera
public struct CameraTransition {

    /// Represents a change to the center coordinate of the map.
    /// NOTE: Setting the `toValue` of `center` overrides any `anchor` animations
    public var center: Change<CLLocationCoordinate2D>

    /// Represents a change to the zoom of the map.
    public var zoom: Change<CGFloat>

    /// Represetns a change to the padding of the map.
    public var padding: Change<UIEdgeInsets>

    /// Represents a change to the anchor of the map
    /// NOTE: Incompatible with concurrent center animations
    public var anchor: Change<CGPoint>

    /// Set this value in order to make bearing/zoom animations
    /// honor a constant anchor throughout the transition
    /// NOTE: Incompatible with concurrent center animations
    public var constantAnchor: CGPoint? {
        set {
            anchor.fromValue = newValue ?? anchor.fromValue
            anchor.toValue = newValue
        }
        get {
            return anchor.fromValue == anchor.toValue ? anchor.fromValue : nil
        }
    }

    /// Represents a change to the bearing of the map.
    public var bearing: Change<CLLocationDirection>

    /// Ensures that bearing transitions are optimized to take the shortest path.
    public var shouldOptimizeBearingPath: Bool = true

    /// Represents a change to the pitch of the map.
    public var pitch: Change<CGFloat>

    /// Generic struct used to represent a change in a value from a starting point (i.e. `fromValue`) to an end point (i.e. `toValue`).
    public struct Change<T> {
        public var fromValue: T
        public var toValue: T?

        init(fromValue: T, toValue: T? = nil) {
            self.fromValue = fromValue
            self.toValue = toValue
        }
    }

    internal init(with renderedCameraOptions: CameraOptions, initialAnchor: CGPoint) {

        guard let renderedCenter = renderedCameraOptions.center,
              let renderedZoom = renderedCameraOptions.zoom,
              let renderedPadding = renderedCameraOptions.padding,
              let renderedPitch = renderedCameraOptions.pitch,
              let renderedBearing = renderedCameraOptions.bearing else {
            fatalError("Values in rendered CameraOptions cannot be nil")
        }

        center  = Change(fromValue: renderedCenter)
        zoom    = Change(fromValue: renderedZoom)
        padding = Change(fromValue: renderedPadding)
        pitch   = Change(fromValue: renderedPitch)
        bearing = Change(fromValue: renderedBearing)
        anchor  = Change(fromValue: initialAnchor)
    }

    internal var toCameraOptions: CameraOptions {
        return CameraOptions(center: center.toValue,
                             padding: padding.toValue,
                             anchor: anchor.toValue,
                             zoom: zoom.toValue,
                             bearing: optimizedBearingToValue,
                             pitch: pitch.toValue)
    }

    internal var fromCameraOptions: CameraOptions {
        return CameraOptions(center: center.fromValue,
                             padding: padding.fromValue,
                             anchor: anchor.fromValue,
                             zoom: zoom.fromValue,
                             bearing: bearing.fromValue,
                             pitch: pitch.fromValue)

    }

    internal var optimizedBearingToValue: CLLocationDirection? {

        // If we should not optimize bearing transition, then return the original `toValue`
        guard shouldOptimizeBearingPath else {
            return bearing.toValue
        }

        // If `bearing.toValue` is nil, then return nil.
        guard let toBearing = bearing.toValue?.truncatingRemainder(dividingBy: 360.0) else {
            return nil
        }

        let fromBearing = bearing.fromValue.truncatingRemainder(dividingBy: 360.0)

        // 180 degrees is the max the map should rotate, therefore if the difference between the end and start point is
        // more than 180 we need to go the opposite direction
        if toBearing - fromBearing >= 180 {
            return toBearing - 360
        }

        // This is the inverse of the above, accounting for negative bearings
        if toBearing - fromBearing <= -180 {
            return toBearing + 360
        }

        return toBearing

    }

}
