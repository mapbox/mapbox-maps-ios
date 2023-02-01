import Foundation
import CoreLocation
import UIKit

public struct CameraOptions: Hashable {
    /// The geographic coordinate that will be rendered at the midpoint of the area defined by `padding`. Defaults to (0, 0).
    public var center: CLLocationCoordinate2D?
    /// Insets from each edge of the map. Impacts the "principal point" of the graphical projection and the location at which `center` is rendered. Defaults to 0. 
    public var padding: UIEdgeInsets?
    /// Point in the map's coordinate system about which `zoom` and `bearing` should be applied. Mutually exclusive with `center`. Defaults to (0, 0).
    public var anchor: CGPoint?
    /// The zoom level of the map. Defaults to 0.
    public var zoom: CGFloat?
    /// The bearing of the map, measured in degrees clockwise from true north. Defaults to 0.
    public var bearing: CLLocationDirection?
    /// Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map. Defaults to 0.
    public var pitch: CGFloat?

    /**
    `CameraOptions` represents a set of updates to make to the camera.

    - Parameter center: The geographic coordinate that will be rendered at the midpoint of the area defined by `padding`.
    - Parameter padding: Insets from each edge of the map. Impacts the "principal point" of the graphical projection and the location at which `center` is rendered.
    - Parameter anchor: Point in the map's coordinate system about which `zoom` and `bearing` should be applied. Mutually exclusive with `center`.
    - Parameter zoom: The zoom level of the map.
    - Parameter bearing: The bearing of the map, measured in degrees clockwise from true north.
    - Parameter pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    - Returns: A `CameraOptions` that contains all configuration information the map will use to determine which part of the map to render.
    */
    public init(center: CLLocationCoordinate2D? = nil,
                padding: UIEdgeInsets? = nil,
                anchor: CGPoint? = nil,
                zoom: CGFloat? = nil,
                bearing: CLLocationDirection? = nil,
                pitch: CGFloat? = nil) {
        self.center     = center
        self.padding 	= padding
        self.anchor     = anchor
        self.zoom 	    = zoom
        self.bearing    = bearing
        self.pitch      = pitch
    }

    public init(cameraState: CameraState, anchor: CGPoint? = nil) {
        self.center     = cameraState.center
        self.padding    = cameraState.padding
        self.zoom       = cameraState.zoom
        self.bearing    = cameraState.bearing
        self.pitch      = cameraState.pitch
        self.anchor     = anchor
    }

    internal init(_ objcValue: MapboxCoreMaps.CameraOptions) {
        self.init(
            center: objcValue.__center?.coordinate,
            padding: objcValue.__padding?.toUIEdgeInsetsValue(),
            anchor: objcValue.__anchor?.point,
            zoom: objcValue.__zoom?.CGFloat,
            bearing: objcValue.__bearing?.CLLocationDirection,
            pitch: objcValue.__pitch?.CGFloat)
    }

    public static func == (lhs: CameraOptions, rhs: CameraOptions) -> Bool {
        return lhs.center?.latitude == rhs.center?.latitude
            && lhs.center?.longitude == rhs.center?.longitude
            && lhs.padding == rhs.padding
            && lhs.anchor == rhs.anchor
            && lhs.zoom == rhs.zoom
            && lhs.bearing == rhs.bearing
            && lhs.pitch == rhs.pitch
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(center?.latitude)
        hasher.combine(center?.longitude)
        hasher.combine(padding?.top)
        hasher.combine(padding?.left)
        hasher.combine(padding?.bottom)
        hasher.combine(padding?.right)
        hasher.combine(anchor?.x)
        hasher.combine(anchor?.y)
        hasher.combine(zoom)
        hasher.combine(bearing)
        hasher.combine(pitch)
    }
}

extension MapboxCoreMaps.CameraOptions {
    internal convenience init(_ swiftValue: CameraOptions) {
        self.init(
            __center: swiftValue.center?.location,
            padding: swiftValue.padding?.toMBXEdgeInsetsValue(),
            anchor: swiftValue.anchor?.screenCoordinate,
            zoom: swiftValue.zoom?.NSNumber,
            bearing: swiftValue.bearing?.NSNumber,
            pitch: swiftValue.pitch?.NSNumber)
    }
}
