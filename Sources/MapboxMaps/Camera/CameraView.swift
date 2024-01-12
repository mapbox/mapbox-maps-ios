import UIKit

/// A view that represents a camera view port.
internal class CameraView: UIView {

    /// returns nil if the presentation layer is nil
    internal var presentationCameraOptions: CameraOptions? {
        // Validate that the presentation has actual initial values
        guard layer.presentation()?.needsDisplayOnBoundsChange == layer.needsDisplayOnBoundsChange else { return nil }
        return layer.presentation().map(cameraOptions(with:))
    }

    internal var cameraOptions: CameraOptions {
        return cameraOptions(with: layer)
    }

    init() {
        super.init(frame: .zero)
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func cameraOptions(with layer: CALayer) -> CameraOptions {
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(layer.position.y),
                                            longitude: CLLocationDegrees(layer.position.x))
        let padding = UIEdgeInsets(top: layer.contentsRect.origin.x,
                                   left: layer.bounds.origin.x,
                                   bottom: layer.contentsRect.origin.y,
                                   right: layer.bounds.origin.y)

        return CameraOptions(
            center: center,
            padding: padding,
            anchor: layer.anchorPoint,
            zoom: CGFloat(layer.opacity),
            bearing: CLLocationDirection(layer.cornerRadius),
            pitch: layer.borderWidth)
    }

    internal func syncLayer(to cameraOptions: CameraOptions) {
        if let zoom = cameraOptions.zoom {
            layer.opacity = Float(zoom)
        }

        if let bearing = cameraOptions.bearing {
            layer.cornerRadius = CGFloat(bearing)
        }

        if let centerCoordinate = cameraOptions.center {
            layer.position = CGPoint(x: centerCoordinate.longitude, y: centerCoordinate.latitude)
        }

        if let padding = cameraOptions.padding {
            layer.bounds.origin = CGPoint(x: padding.left, y: padding.right)
            layer.contentsRect.origin = CGPoint(x: padding.top, y: padding.bottom)
        }

        if let pitch = cameraOptions.pitch {
            layer.borderWidth = pitch
        }

        if let anchor = cameraOptions.anchor {
            layer.anchorPoint = anchor
        }
    }
}
