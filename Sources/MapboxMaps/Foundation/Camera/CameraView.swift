import UIKit

/// Internal protocol that provides needed information / methods for the `CameraView`
internal protocol CameraViewDelegate: class {
    /// The map's current camera
    var camera: CameraOptions { get }

    /// The map's current center coordinate.
    var centerCoordinate: CLLocationCoordinate2D { get }

    /// The map's  zoom level.
    var zoom: CGFloat { get }

    /// The map's bearing, measured clockwise from 0° north.
    var bearing: CLLocationDirection { get }

    /// The map's pitch, falling within a range of 0 to 60.
    var pitch: CGFloat { get }

    /// The map's camera padding
    var padding: UIEdgeInsets { get }

    /// The map's camera anchor
    var anchor: CGPoint { get }

    /// The map should jumpt to some camera
    func jumpTo(camera: CameraOptions)
}

/// A view that represents a camera view port.
internal class CameraView: UIView {

    public var camera: CameraOptions {
        get {
            return delegate.camera
        }
        set {
            if let newZoom = newValue.zoom {
                zoom = newZoom
            }

            if let newBearing = newValue.bearing {
                bearing = CGFloat(newBearing)
            }

            if let newPitch = newValue.pitch {
                pitch = newPitch
            }

            if let newPadding = newValue.padding {
                padding = newPadding
            }

            if let newAnchor = newValue.anchor {
                anchor = newAnchor
            }

            if let newCenterCoordinate = newValue.center {
                centerCoordinate = newCenterCoordinate
            }
        }
    }

    /// The camera's zoom. Animatable.
    @objc dynamic public var zoom: CGFloat {
        get {
            return delegate.zoom
        }
        set {
            layer.opacity = Float(newValue)
        }
    }

    /// The camera's bearing. Animatable.
    @objc dynamic public var bearing: CGFloat {
        get {
            return CGFloat(delegate.bearing)
        }

        set {
            layer.cornerRadius = newValue
        }
    }

    /// Coordinate at the center of the camera. Animatable.
    @objc dynamic public var centerCoordinate: CLLocationCoordinate2D {
        get {
            return delegate.centerCoordinate
        }

        set {
            layer.position = CGPoint(x: newValue.longitude, y: newValue.latitude)
        }
    }

    /// The camera's padding. Animatable.
    @objc dynamic public var padding: UIEdgeInsets {
        get {
            return delegate.padding
        }
        set {
            layer.bounds = CGRect(x: newValue.left,
                                  y: newValue.right,
                                  width: newValue.bottom,
                                  height: newValue.top)
        }
    }

    /// The camera's pitch. Animatable.
    @objc dynamic public var pitch: CGFloat {
        get {
            return delegate.pitch
        }
        set {
            layer.zPosition = newValue
        }
    }

    /// The screen coordinate that the map rotates, pitches and zooms around. Setting this also affects the horizontal vanishing point when pitched. Animatable.
    @objc dynamic public var anchor: CGPoint {
        get {
            return layer.presentation()?.anchorPoint ?? layer.anchorPoint
        }

        set {
            layer.anchorPoint = newValue
        }
    }

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
        return layer.presentation()?.zPosition ?? layer.zPosition
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

    private unowned var delegate: CameraViewDelegate!

    init(delegate: CameraViewDelegate, edgeInsets: UIEdgeInsets = .zero) {
        self.delegate = delegate
        super.init(frame: .zero)

        self.isHidden = true
        self.isUserInteractionEnabled = false

        // Sync default values from MBXMap
        setFromValuesWithMapView()
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setFromValuesWithMapView() {
        zoom = delegate.zoom
        bearing = CGFloat(delegate.bearing)
        pitch = delegate.pitch
        padding = delegate.padding
        centerCoordinate = delegate.centerCoordinate
    }

    internal func update() {

        // Retrieve currently rendered camera
        let currentCamera = delegate.camera

        // Get the latest interpolated values of the camera properties (if they exist)
        let targetCamera = localCamera.wrap()

        // Apply targetCamera options only if they are different from currentCamera options
        if currentCamera != targetCamera {

            // Diff the targetCamera with the currentCamera and apply diffed camera properties to map
            let diffedCamera = CameraOptions()

            if targetCamera.zoom != currentCamera.zoom {
                diffedCamera.zoom = targetCamera.zoom
            }

            if targetCamera.bearing != currentCamera.bearing {
                diffedCamera.bearing = targetCamera.bearing
            }

            if targetCamera.pitch != currentCamera.pitch {
                diffedCamera.pitch = targetCamera.pitch
            }

            if targetCamera.center != currentCamera.center {
                diffedCamera.center = targetCamera.center
            }

            if targetCamera.anchor != currentCamera.anchor {
                diffedCamera.anchor = targetCamera.anchor
            }

            if targetCamera.padding != currentCamera.padding {
                diffedCamera.padding = targetCamera.padding
            }

            delegate.jumpTo(camera: diffedCamera)
        }
    }
}

fileprivate extension CameraOptions {

    func wrap() -> CameraOptions {
        return CameraOptions(center: self.center?.wrap(),
                             padding: self.padding,
                             anchor: self.anchor,
                             zoom: self.zoom,
                             bearing: self.bearing,
                             pitch: self.pitch)

    }
}
