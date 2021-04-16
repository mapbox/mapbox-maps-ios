import UIKit

/// A view that represents a camera view port.
internal class CameraView: UIView {
    
    internal var localCenterCoordinate: CLLocationCoordinate2D {
        let proxyCoord = layer.presentation()?.position ?? layer.position
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(proxyCoord.y),
                                      longitude: CLLocationDegrees(proxyCoord.x))
    }

    internal var localZoom: CGFloat {
        return CGFloat(layer.presentation()?.opacity ?? layer.opacity)
    }

    internal var localBearing: CLLocationDirection {
        return CLLocationDirection(layer.presentation()?.cornerRadius ?? layer.cornerRadius)
    }

    internal var localPitch: CGFloat {
        return layer.presentation()?.transform.m11 ?? layer.transform.m11
    }

    internal var localAnchorPoint: CGPoint {
        return layer.presentation()?.anchorPoint ?? layer.anchorPoint
    }

    internal var localPadding: UIEdgeInsets {
        let proxyPadding = layer.presentation()?.bounds ?? layer.bounds
        return UIEdgeInsets(top: proxyPadding.size.height,
                            left: proxyPadding.origin.x,
                            bottom: proxyPadding.size.width,
                            right: proxyPadding.origin.y)
    }

    internal var localCamera: CameraOptions {
        return CameraOptions(center: localCenterCoordinate,
                             padding: localPadding,
                             anchor: localAnchorPoint,
                             zoom: localZoom,
                             bearing: localBearing,
                             pitch: localPitch)
    }

    init() {
        super.init(frame: .zero)
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

