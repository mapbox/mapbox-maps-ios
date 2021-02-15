import Foundation
import CoreLocation
import UIKit

public extension CameraOptions {

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
    convenience init(center: CLLocationCoordinate2D? = nil,
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

    var center: CLLocationCoordinate2D? {
        get {
            return __center?.coordinate
        }
        set {
            __center = newValue?.location
        }
    }

    var padding: UIEdgeInsets? {
        get {
            return __padding?.toUIEdgeInsetsValue()
        }
        set {
            __padding = newValue?.toMBXEdgeInsetsValue()
        }
    }

    var anchor: CGPoint? {
        get {
            return __anchor?.point
        }
        set {
            __anchor = newValue?.screenCoordinate
        }
    }

    var zoom: CGFloat? {
        get {
            return __zoom?.CGFloat
        }
        set {
            __zoom = newValue?.NSNumber
        }
    }

    var bearing: CLLocationDirection? {
        get {
            return __bearing?.CLLocationDirection
        }
        set {
            __bearing = newValue?.NSNumber
        }
    }

    var pitch: CGFloat? {
        get {
            return __pitch?.CGFloat
        }
        set {
            __pitch = newValue?.NSNumber
        }
    }
}

extension CameraOptions {
    public static func == (lhs: CameraOptions, rhs: CameraOptions) -> Bool {
        return lhs.center == rhs.center &&
               lhs.padding == rhs.padding &&
               lhs.anchor == rhs.anchor &&
               lhs.zoom == rhs.zoom &&
               lhs.bearing == rhs.bearing &&
               lhs.pitch == rhs.pitch
    }
}
