import UIKit
import CoreLocation

// Represents a change in a camera property due to an animation
internal enum AnimatableCameraProperty: Hashable {
    
    case center(start: CLLocationCoordinate2D? = nil, end: CLLocationCoordinate2D? = nil)
    
    case bearing(start: Double? = nil, end: Double? = nil)
    
    case pitch(start: CGFloat? = nil, end: CGFloat? = nil)
    
    case anchor(end: CGPoint? = nil)
    
    case padding(start: UIEdgeInsets? = nil, end: UIEdgeInsets? = nil)
    
    case zoom(start: CGFloat? = nil, end: CGFloat? = nil)
    
    internal static func diffChangesToCameraOptions(from renderedCameraOptions: CameraOptions,
                                             to animatedCameraOptions: CameraOptions) -> Set<AnimatableCameraProperty> {
        
        var changes = Set<AnimatableCameraProperty>()
        
        if let startCenter = renderedCameraOptions.center,
           let endCenter = animatedCameraOptions.center,
           startCenter != endCenter {
            changes.insert(.center(start: startCenter, end: endCenter))
        }
        
        if let startBearing = renderedCameraOptions.bearing,
           let endBearing = animatedCameraOptions.bearing,
           startBearing != endBearing {
            changes.insert(.bearing(start: startBearing, end: endBearing))
        }
        
        if let startPitch = renderedCameraOptions.pitch,
           let endPitch = animatedCameraOptions.pitch,
           startPitch != endPitch {
            changes.insert(.pitch(start: startPitch, end: endPitch))
        }
        
        if let endAnchor = animatedCameraOptions.anchor { // Special case for anchor???
            changes.insert(.anchor(end: endAnchor))
        }
        
        if let startPadding = renderedCameraOptions.padding,
           let endPadding = animatedCameraOptions.padding,
           startPadding != endPadding {
            changes.insert(.padding(start: startPadding, end: endPadding))
        }
        
        if let startZoom = renderedCameraOptions.zoom,
           let endZoom = animatedCameraOptions.zoom,
           startZoom != endZoom {
            changes.insert(.zoom(start: startZoom, end: endZoom))
        }
        
        return changes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    enum Keypaths {
        static let center   = \CameraOptions.center
        static let anchor   = \CameraOptions.anchor
        static let padding  = \CameraOptions.anchor
        static let zoom     = \CameraOptions.zoom
        static let pitch    = \CameraOptions.pitch
        static let bearing  = \CameraOptions.bearing
    }
    
    var name: String {
        switch self {
        case .center(start: _, end: _):
            return "center"
        case .bearing(start: _, end: _):
            return "bearing"
        case .pitch(start: _, end: _):
            return "pitch"
        case .anchor(end: _):
            return "anchor"
        case .padding(start: _, end: _):
            return "padding"
        case .zoom(start: _, end: _):
            return "zoom"
        }
    }
}
