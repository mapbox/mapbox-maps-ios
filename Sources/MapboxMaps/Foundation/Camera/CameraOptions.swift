import Foundation
import CoreLocation
import UIKit

extension CameraOptions {

    /**
    The `CameraOptions` object contains information about the current state of the camera.

    - Parameter centerCoordinate: The map coordinate that will represent the center of the viewport.
    - Parameter padding: The padding surrounding the `CameraView`'s viewport. Defaults to nil.
    - Parameter anchor: Point in this `CameraView`'s coordinate system on which to “anchor”
                        responses to user-initiated gestures.
    - Parameter zoom: The zoom level of the map. Defaults to nil.
    - Bearing bearing: The bearing of the viewport, measured in degrees clockwise from true north.
    - Parameter pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a two-dimensional map.
    - Returns: A `CameraOptions` object that contains all configuration information the `CameraView`
               will use to render the map's viewport.
    */
    public convenience init(center: CLLocationCoordinate2D? = nil,
                            padding: UIEdgeInsets? = nil,
                            anchor: CGPoint? = nil,
                            zoom: CGFloat? = nil,
                            bearing: CLLocationDirection? = nil,
                            pitch: CGFloat? = nil) {
        self.init(__center: center?.location,
                  padding: padding?.toMBXEdgeInsetsValue(),
                  anchor: anchor?.screenCoordinate,
                  zoom: zoom?.NSNumber,
                  bearing: bearing?.NSNumber,
                  pitch: pitch?.NSNumber)
    }

    public var center: CLLocationCoordinate2D? {
        get {
            return __center?.coordinate
        }
        set {
            __center = newValue?.location
        }
    }

    public var padding: UIEdgeInsets? {
        get {
            return __padding?.toUIEdgeInsetsValue()
        }
        set {
            __padding = newValue?.toMBXEdgeInsetsValue()
        }
    }

    public var anchor: CGPoint? {
        get {
            return __anchor?.point
        }
        set {
            __anchor = newValue?.screenCoordinate
        }
    }

    public var zoom: CGFloat? {
        get {
            return __zoom?.CGFloat
        }
        set {
            __zoom = newValue?.NSNumber
        }
    }

    public var bearing: CLLocationDirection? {
        get {
            return __bearing?.CLLocationDirection
        }
        set {
            __bearing = newValue?.NSNumber
        }
    }

    public var pitch: CGFloat? {
        get {
            return __pitch?.CGFloat
        }
        set {
            __pitch = newValue?.NSNumber
        }
    }

    override open func isEqual(_ object: Any?) -> Bool {
        guard let otherCameraOption = object as? CameraOptions else {
            return false
        }

        return center == otherCameraOption.center &&
               padding == otherCameraOption.padding &&
               anchor == otherCameraOption.anchor &&
               zoom == otherCameraOption.zoom &&
               bearing == otherCameraOption.bearing &&
               pitch == otherCameraOption.pitch
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(center)
        hasher.combine(padding)
        hasher.combine(zoom)
        hasher.combine(anchor)
        hasher.combine(bearing)
        hasher.combine(pitch)
        return hasher.finalize()
    }
}
