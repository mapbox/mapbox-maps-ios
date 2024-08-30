import Foundation
import CoreLocation
import UIKit

public struct CameraOptions: Codable, Hashable, Sendable {
    /// The geographic coordinate that will be rendered at the midpoint of the area defined by `padding`. Defaults to (0, 0).
    public var center: CLLocationCoordinate2D? {
        get { centerCodable?.coordinates }
        set { centerCodable = newValue.map(CLLocationCoordinate2DCodable.init) }
    }

    /// Insets from each edge of the map. Impacts the "principal point" of the graphical projection and the location at which `center` is rendered. Defaults to 0.
    public var padding: UIEdgeInsets? {
        get { paddingCodable?.edgeInsets }
        set { paddingCodable = newValue.map(UIEdgeInsetsCodable.init) }
    }

    /// Point in the map's coordinate system about which `zoom` and `bearing` should be applied. Mutually exclusive with `center`. Defaults to (0, 0).
    public var anchor: CGPoint? {
        get { anchorCodable?.point }
        set { anchorCodable = newValue.map(CGPointCodable.init) }
    }

    /// The zoom level of the map. Defaults to 0.
    public var zoom: CGFloat?
    /// The bearing of the map, measured in degrees clockwise from true north. Defaults to 0.
    public var bearing: CLLocationDirection?
    /// Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map. Defaults to 0.
    public var pitch: CGFloat?

    private var centerCodable: CLLocationCoordinate2DCodable?
    private var paddingCodable: UIEdgeInsetsCodable?
    private var anchorCodable: CGPointCodable?

    /**
    `CameraOptions` represents a set of updates to make to the camera.

    - Parameter center: The geographic coordinate that will be rendered at the midpoint of the area defined by `padding`.
    - Parameter padding: Insets from each edge of the map. Impacts the "principal point" of the graphical projection and the location at which `center` is rendered.
    - Parameter anchor: Point in the map's coordinate system about which `zoom` and `bearing` should be applied. Mutually exclusive with `center`.
    - Parameter zoom: The zoom level of the map.
    - Parameter bearing: The bearing of the map, measured in degrees clockwise from true north.
    - Parameter pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    */
    public init(center: CLLocationCoordinate2D? = nil,
                padding: UIEdgeInsets? = nil,
                anchor: CGPoint? = nil,
                zoom: CGFloat? = nil,
                bearing: CLLocationDirection? = nil,
                pitch: CGFloat? = nil) {
        self.center     = center
        self.padding    = padding
        self.anchor     = anchor
        self.zoom       = zoom
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

    internal init(_ objcValue: CoreCameraOptions) {
        self.init(
            center: objcValue.__center?.value,
            padding: objcValue.__padding?.toUIEdgeInsetsValue(),
            anchor: objcValue.__anchor?.point,
            zoom: objcValue.__zoom?.CGFloat,
            bearing: objcValue.__bearing?.CLLocationDirection,
            pitch: objcValue.__pitch?.CGFloat)
    }
}

extension CoreCameraOptions {
    internal convenience init(_ swiftValue: CameraOptions) {
        self.init(
            __center: swiftValue.center.flatMap { Coordinate2D(value: $0) },
            padding: swiftValue.padding?.toMBXEdgeInsetsValue(),
            anchor: swiftValue.anchor?.screenCoordinate,
            zoom: swiftValue.zoom?.NSNumber,
            bearing: swiftValue.bearing?.NSNumber,
            pitch: swiftValue.pitch?.NSNumber)
    }
}
