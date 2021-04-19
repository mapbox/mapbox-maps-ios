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
        
        guard let renderedCenter    = renderedCameraOptions.center,
              let renderedZoom      = renderedCameraOptions.zoom,
              let renderedPadding   = renderedCameraOptions.padding,
              let renderedPitch     = renderedCameraOptions.pitch,
              let renderedBearing   = renderedCameraOptions.bearing else {
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
        cameraOptions.bearing   = bearing.toValue
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
}
