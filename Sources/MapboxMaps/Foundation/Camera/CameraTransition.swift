import UIKit
import CoreLocation

/// Structure used to represent a desired change to the map's camera
public struct CameraTransition {

    /// Represents a change to the center coordinate of the map.
    public var center: Change<CLLocationCoordinate2D>

    /// Represents a change to the zoom of the map.
    public var zoom: Change<CGFloat>

    /// Represetns a change to the padding of the map.
    public var padding: Change<UIEdgeInsets>

    /// Represents a change to the anchor of the map
    public var anchor: Change<CGPoint>

    /// Represents a change to the bearing of the map.
    public var bearing: Change<Double>

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

        center  = .init(fromValue: renderedCenter)
        zoom    = .init(fromValue: renderedZoom)
        padding = .init(fromValue: renderedPadding)
        pitch   = .init(fromValue: renderedPitch)
        bearing = .init(fromValue: renderedBearing)
        anchor  = .init(fromValue: initialAnchor)
    }

    internal var toCameraOptions: CameraOptions {

        let cameraOptions = CameraOptions()
        cameraOptions.anchor    = anchor.toValue
        cameraOptions.bearing   = shouldOptimizeBearingPath ? Self.optimizeBearing(startBearing: bearing.fromValue, endBearing: bearing.toValue) :  bearing.toValue

        cameraOptions.padding   = padding.toValue
        cameraOptions.center    = center.toValue
        cameraOptions.zoom      = zoom.toValue
        cameraOptions.pitch     = pitch.toValue

        return cameraOptions
    }

    internal var fromCameraOptions: CameraOptions {

        let cameraOptions = CameraOptions()
        cameraOptions.anchor    = anchor.fromValue
        cameraOptions.bearing   = bearing.fromValue
        cameraOptions.padding   = padding.fromValue
        cameraOptions.center    = center.fromValue
        cameraOptions.zoom      = zoom.fromValue
        cameraOptions.pitch     = pitch.fromValue

        return cameraOptions
    }

    /// This function optimizes the bearing for set camera so that it is taking the shortest path.
    /// - Parameters:
    ///   - startBearing: The current or start bearing of the map viewport.
    ///   - endBearing: The bearing of where the map viewport should end at.
    /// - Returns: A `CLLocationDirection` that represents the correct final bearing accounting for positive and negatives.
    internal static func optimizeBearing(startBearing: CLLocationDirection?, endBearing: CLLocationDirection?) -> CLLocationDirection? {
        // This modulus is required to account for larger values
        guard
            let startBearing = startBearing?.truncatingRemainder(dividingBy: 360.0),
            let endBearing = endBearing?.truncatingRemainder(dividingBy: 360.0)
        else {
            return nil
        }

        // 180 degrees is the max the map should rotate, therefore if the difference between the end and start point is
        // more than 180 we need to go the opposite direction
        if endBearing - startBearing >= 180 {
            return endBearing - 360
        }

        // This is the inverse of the above, accounting for negative bearings
        if endBearing - startBearing <= -180 {
            return endBearing + 360
        }

        return endBearing
    }

}
