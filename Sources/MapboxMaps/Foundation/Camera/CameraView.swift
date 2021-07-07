import UIKit

/// A view that represents a camera view port.
internal class CameraView: UIView {

    /// returns nil if the presentation layer is nil
    internal var presentationCameraOptions: CameraOptions? {
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
        return CameraOptions(
            center: CLLocationCoordinate2D(
                latitude: CLLocationDegrees(layer.position.y),
                longitude: CLLocationDegrees(layer.position.x)),
            padding: UIEdgeInsets(
                top: layer.bounds.size.height,
                left: layer.bounds.origin.x,
                bottom: layer.bounds.size.width,
                right: layer.bounds.origin.y),
            anchor: layer.anchorPoint,
            zoom: CGFloat(layer.opacity),
            bearing: CLLocationDirection(layer.cornerRadius),
            pitch: layer.transform.m11)
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
            layer.bounds = CGRect(x: padding.left,
                                  y: padding.right,
                                  width: padding.bottom,
                                  height: padding.top)
        }

        if let pitch = cameraOptions.pitch {
            layer.transform.m11 = pitch
        }

        if let anchor = cameraOptions.anchor {
            layer.anchorPoint = anchor
        }
    }
}
