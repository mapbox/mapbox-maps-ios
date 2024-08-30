import UIKit
import CoreLocation

/// Structure used to represent a desired change to the map's camera
public struct CameraTransition: Equatable, Sendable {

    /// Represents a change to the center coordinate of the map.
    /// NOTE: Setting the `toValue` of `center` overrides any `anchor` animations
    public var center: Change<CLLocationCoordinate2D>

    /// Represents a change to the zoom of the map.
    public var zoom: Change<CGFloat>

    /// Represents a change to the padding of the map.
    public var padding: Change<UIEdgeInsets>

    /// Represents a change to the anchor of the map
    /// NOTE: Incompatible with concurrent center animations
    public var anchor: Change<CGPoint>

    /// Represents a change to the bearing of the map.
    public var bearing: Change<CLLocationDirection>

    /// Ensures that bearing transitions are optimized to take the shortest path. Defaults to `true`.
    public var shouldOptimizeBearingPath: Bool = true

    /// Represents a change to the pitch of the map.
    public var pitch: Change<CGFloat>

    /// Generic struct used to represent a change in a value from a starting point (i.e. `fromValue`) to an end point (i.e. `toValue`).
    public struct Change<T>: Equatable where T: Equatable {
        public var fromValue: T
        public var toValue: T?

        init(fromValue: T, toValue: T? = nil) {
            self.fromValue = fromValue
            self.toValue = toValue
        }
    }

    internal init(cameraState: CameraState, initialAnchor: CGPoint) {
        center  = Change(fromValue: cameraState.center)
        zoom    = Change(fromValue: cameraState.zoom)
        padding = Change(fromValue: cameraState.padding)
        pitch   = Change(fromValue: cameraState.pitch)
        bearing = Change(fromValue: cameraState.bearing)
        anchor  = Change(fromValue: initialAnchor)
    }

    internal var toCameraOptions: CameraOptions {
        return CameraOptions(center: center.toValue,
                             padding: padding.toValue,
                             anchor: anchor.toValue,
                             zoom: zoom.toValue,
                             bearing: shouldOptimizeBearingPath ? optimizedBearingToValue : bearing.toValue,
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

        // If `bearing.toValue` is nil, then return nil.
        guard let toBearing = bearing.toValue?.truncatingRemainder(dividingBy: 360.0) else {
            return nil
        }

        let fromBearing = bearing.fromValue

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

extension CameraTransition.Change: Sendable where T: Sendable {}
