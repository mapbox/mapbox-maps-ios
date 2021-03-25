import QuartzCore
import CoreLocation
import UIKit.UIGeometry

/// An object that manages a map camera content and allows you to perform animations.
public class CameraLayer: CALayer {
    /// The camera zoom.
    @NSManaged public var zoom: CGFloat

    /// The camera bearing.
    @NSManaged public var bearing: CGFloat

    /// The camera's center latitude.
    @NSManaged public var centerCoordinateLatitude: CGFloat

    /// The camera's center longitude.
    @NSManaged public var centerCoordinateLongitude: CGFloat

    /// The camera's anchor
    public var anchor: CGPoint = CGPoint.zero

    /// The camera's padding
    public var padding: UIEdgeInsets = UIEdgeInsets.zero

    /// The camera's pitch
    @NSManaged public var pitch: CGFloat

    public override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? CameraLayer {
            zoom = layer.zoom
            bearing = layer.bearing
            centerCoordinateLatitude = layer.centerCoordinateLatitude
            centerCoordinateLongitude = layer.centerCoordinateLongitude
            anchor = layer.anchor
            pitch = layer.pitch
            padding = layer.padding
        }
    }

    public override init() {
        super.init()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public class func customAnimatableProperty(forKey key: String) -> Bool {
        return key == "zoom"
            || key == "centerCoordinateLatitude"
            || key == "centerCoordinateLongitude"
            || key == "bearing"
            || key == "pitch"
    }

    public override class func needsDisplay(forKey key: String) -> Bool {
        if customAnimatableProperty(forKey: key) {
            return true
        }

        return super.needsDisplay(forKey: key)
    }

    public override func action(forKey key: String) -> CAAction? {

        if CameraLayer.customAnimatableProperty(forKey: key) {
            // This does NOT work for UIViewPropertyAnimators or for UIView.animate with keyframe
            // animations.
            guard let animation = currentAnimationContext()?.copy() as? CABasicAnimation else {
                setNeedsDisplay()
                return nil
            }
            animation.keyPath = key
            if let presentation = presentation() {
                animation.fromValue = presentation.value(forKeyPath: key)
            }
            animation.toValue = nil
            return animation
        }

        return super.action(forKey: key)
    }

    private func currentAnimationContext() -> CABasicAnimation? {
        /// Use backgroundColor animatable property to serve as base context for our custom animatable
        /// properties.
        return action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation
    }

}
