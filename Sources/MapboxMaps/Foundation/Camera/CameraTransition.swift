import UIKit
import CoreLocation

public struct CameraTransition {
    
    public var center: Change<CLLocationCoordinate2D>
    public var zoom: Change<CGFloat>
    public var padding: Change<UIEdgeInsets>
    public var anchor: Change<CGPoint>
    public var bearing: Change<Double>
    public var pitch: Change<CGFloat>
    
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
        
        center = Change<CLLocationCoordinate2D>(fromValue: renderedCenter)
        zoom = Change<CGFloat>(fromValue: renderedZoom)
        padding = Change<UIEdgeInsets>(fromValue: renderedPadding)
        pitch = Change<CGFloat>(fromValue: renderedPitch)
        bearing = Change<Double>(fromValue: renderedBearing)
        anchor = Change<CGPoint>(fromValue: initialAnchor)
    }
    
    internal var toCameraOptions: CameraOptions {
        
        let cameraOptions = CameraOptions()
        cameraOptions.anchor = anchor.toValue
        cameraOptions.bearing = bearing.toValue
        cameraOptions.padding = padding.toValue
        cameraOptions.center = center.toValue
        cameraOptions.zoom = zoom.toValue
        cameraOptions.pitch = pitch.toValue
        
        return cameraOptions
    }
    
    internal var fromCameraOptions: CameraOptions {
        
        let cameraOptions = CameraOptions()
        cameraOptions.anchor = anchor.fromValue
        cameraOptions.bearing = bearing.fromValue
        cameraOptions.padding = padding.fromValue
        cameraOptions.center = center.fromValue
        cameraOptions.zoom = zoom.fromValue
        cameraOptions.pitch = pitch.fromValue
        
        return cameraOptions
    }
}
