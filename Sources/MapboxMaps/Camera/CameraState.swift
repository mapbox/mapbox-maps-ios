import Foundation
import CoreLocation
import UIKit

public struct CameraState: Hashable {
    public var center: CLLocationCoordinate2D
    public var padding: UIEdgeInsets
    public var zoom: CGFloat
    public var bearing: CLLocationDirection
    public var pitch: CGFloat

    public init(center: CLLocationCoordinate2D,
                padding: UIEdgeInsets,
                zoom: CGFloat,
                bearing: CLLocationDirection,
                pitch: CGFloat) {
        self.center = center
        self.padding = padding
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }

    internal init(_ objcValue: MapboxCoreMaps.CameraState) {
        self.center = objcValue.center
        self.padding = objcValue.padding.toUIEdgeInsetsValue()
        self.zoom = CGFloat(objcValue.zoom)
        self.bearing = CLLocationDirection(objcValue.bearing)
        self.pitch = CGFloat(objcValue.pitch)
    }

    public static func == (lhs: CameraState, rhs: CameraState) -> Bool {
        return lhs.center.latitude == rhs.center.latitude
            && lhs.center.longitude == rhs.center.longitude
            && lhs.padding == rhs.padding
            && lhs.zoom == rhs.zoom
            && lhs.bearing == rhs.bearing
            && lhs.pitch == rhs.pitch
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(center.latitude)
        hasher.combine(center.longitude)
        hasher.combine(padding.top)
        hasher.combine(padding.left)
        hasher.combine(padding.bottom)
        hasher.combine(padding.right)
        hasher.combine(zoom)
        hasher.combine(bearing)
        hasher.combine(pitch)
    }
}
