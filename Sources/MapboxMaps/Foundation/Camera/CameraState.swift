import Foundation
import CoreLocation
import UIKit

public struct CameraState: Hashable {
    public let center: CLLocationCoordinate2D
    public let padding: UIEdgeInsets
    public let zoom: CGFloat
    public let bearing: CLLocationDirection
    public let pitch: CGFloat
    
    internal init(_ objcValue: MapboxCoreMaps.CameraState) {
        self.center     = objcValue.center
        self.padding    = objcValue.padding.toUIEdgeInsetsValue()
        self.zoom       = CGFloat(objcValue.zoom)
        self.bearing    = CLLocationDirection(objcValue.bearing)
        self.pitch      = CGFloat(objcValue.pitch)
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

extension MapboxCoreMaps.CameraState {
    
    open override func isEqual(_ object: Any?) -> Bool {
        
        guard let other = object as? MapboxCoreMaps.CameraState else {
            return false
        }
        
        return
            center == other.center &&
            padding.toUIEdgeInsetsValue() == other.padding.toUIEdgeInsetsValue() &&
            zoom == other.zoom &&
            pitch == other.pitch &&
            bearing == other.bearing
    }
    
}
