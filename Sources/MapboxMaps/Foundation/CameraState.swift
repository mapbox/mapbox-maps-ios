import Foundation
import CoreLocation
import UIKit

public struct CameraState: Codable, Hashable, Sendable {
    /// The geographic coordinate that will be rendered at the midpoint of the area defined by `padding`.
    public var center: CLLocationCoordinate2D {
        get { centerCodable.coordinates }
        set { centerCodable.coordinates = newValue }
    }

    /// Insets from each edge of the map. Impacts the "principal point" of the graphical projection and the location at which `center` is rendered.
    public var padding: UIEdgeInsets {
        get { paddingCodable.edgeInsets }
        set { paddingCodable.edgeInsets = newValue }
    }

    private var centerCodable: CLLocationCoordinate2DCodable
    private var paddingCodable: UIEdgeInsetsCodable

    /// The zoom level of the map.
    public var zoom: CGFloat
    /// The bearing of the map, measured in degrees clockwise from true north.
    public var bearing: CLLocationDirection
    /// Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    public var pitch: CGFloat

    public init(center: CLLocationCoordinate2D,
                padding: UIEdgeInsets,
                zoom: CGFloat,
                bearing: CLLocationDirection,
                pitch: CGFloat) {
        self.centerCodable = .init(center)
        self.paddingCodable = .init(padding)
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }
}

extension CameraState {
    internal init(_ objcValue: CoreCameraState) {
        self.centerCodable = .init(objcValue.center)
        self.paddingCodable = .init(objcValue.padding.toUIEdgeInsetsValue())
        self.zoom = CGFloat(objcValue.zoom)
        self.bearing = CLLocationDirection(objcValue.bearing)
        self.pitch = CGFloat(objcValue.pitch)
    }
}

extension CoreCameraState {
    internal convenience init(_ swiftValue: CameraState) {
        self.init(
            center: swiftValue.center,
            padding: swiftValue.padding.toMBXEdgeInsetsValue(),
            zoom: swiftValue.zoom,
            bearing: swiftValue.bearing,
            pitch: swiftValue.pitch)
    }
}
