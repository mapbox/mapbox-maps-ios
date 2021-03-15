import UIKit

public protocol CameraViewDelegate: AnyObject {
    /// A method that is called whenever the cameraView is manipulated
    func cameraViewManipulated(for cameraView: CameraView)
}

/// A view that represents a camera view port.
public class CameraView: UIView {

    public override class var layerClass: AnyClass {
        return CameraLayer.self
    }

    private var cameraLayer: CameraLayer {
        // swiftlint:disable force_cast
        return layer as! CameraLayer
        // swiftlint:enable force_cast
    }

    public var camera: CameraOptions {
        get {
            let camera = CameraOptions(center: centerCoordinate,
                                       padding: padding,
                                       anchor: anchor,
                                       zoom: zoom,
                                       bearing: CLLocationDirection(bearing),
                                       pitch: pitch)
            return camera
        }

        set {
            if let zoom = newValue.zoom {
                self.zoom = zoom
            }

            if let bearing = newValue.bearing {
                self.bearing = CGFloat(bearing)
            }

            if let pitch = newValue.pitch {
                self.pitch = pitch
            }

            if let padding = newValue.padding {
                self.padding = padding
            }

            if let anchor = newValue.anchor {
                self.anchor = anchor
            }

            if let centerCoordinate = newValue.center {
                self.centerCoordinate = centerCoordinate
            }
        }

    }

    /// The camera's zoom. Animatable.
    @objc dynamic public var zoom: CGFloat {
        get {
            return cameraLayer.zoom
        }

        set {
            cameraLayer.zoom = newValue
        }
    }

    /// The camera's bearing. Animatable.
    @objc dynamic public var bearing: CGFloat {
        get {
            return cameraLayer.bearing
        }

        set {
            cameraLayer.bearing = newValue
        }
    }

    /// The camera's anchor. Not Animatable.
    /// The anchor will be updated in the next rendering frame.
    @objc dynamic public var anchor: CGPoint {
        get {
            return cameraLayer.anchor
        }

        set {
            cameraLayer.anchor = newValue
        }
    }

    /// The camera's padding around the interior of the view that affects the frame
    /// of reference for centerCoordinate. Not Animatable.
    /// The padding will be updated in the next rendering frame.
    @objc dynamic public var padding: UIEdgeInsets {
        get {
            return cameraLayer.padding
        }

        set {
            cameraLayer.padding = newValue
        }
    }

    /// Coordinate at the center of the camera. Animatable.
    @objc dynamic public var centerCoordinate: CLLocationCoordinate2D {
        get {
            let latitude = CLLocationDegrees(cameraLayer.centerCoordinateLatitude)
            let longitude = CLLocationDegrees(cameraLayer.centerCoordinateLongitude)
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        set {
            cameraLayer.centerCoordinateLatitude = CGFloat(newValue.latitude)
            cameraLayer.centerCoordinateLongitude = CGFloat(newValue.longitude)
        }

    }

    /// The camera's pitch. Animatable.
    @objc dynamic public var pitch: CGFloat {
        get {
            return cameraLayer.pitch
        }

        set {
            cameraLayer.pitch = newValue
        }
    }

    @objc public var visibleCoordinateBounds: CoordinateBounds {
        let padding = self.padding.toMBXEdgeInsetsValue()
        let currentCamera = try! map.getCameraOptions(forPadding: padding)
        return try! map.coordinateBoundsForCamera(forCamera: currentCamera)
    }

    private var map: Map

    public weak var delegate: CameraViewDelegate?

    public init(frame: CGRect, map: Map) {
        self.map = map

        super.init(frame: frame)

        // Sync default values from renderer
        let defaultCameraOptions = try! self.map.getCameraOptions(forPadding: nil)
        zoom = defaultCameraOptions.zoom ?? 0.0
        bearing = CGFloat(defaultCameraOptions.bearing ?? 0.0)
        anchor = defaultCameraOptions.anchor ?? .zero
        pitch = defaultCameraOptions.pitch ?? 0.0
        padding = defaultCameraOptions.padding ?? .zero

        if let coordinate = defaultCameraOptions.center {
            centerCoordinate = coordinate
        }

        translatesAutoresizingMaskIntoConstraints = false
    }

    public convenience init(frame: CGRect, map: Map, camera: CameraOptions) {
        self.init(frame: frame, map: map)
        self.camera = camera
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func display(_ layer: CALayer) {

        let displayLayer = layer.presentation() ?? layer

        if let cameraLayer = displayLayer as? CameraLayer {

            let zoom = NSNumber(value: Double(cameraLayer.zoom))
            let bearing = NSNumber(value: Double(cameraLayer.bearing))
            let anchor = ScreenCoordinate(x: Double(cameraLayer.anchor.x),
                                          y: Double(cameraLayer.anchor.y))

            let padding = cameraLayer.padding.toMBXEdgeInsetsValue()
            let pitch = NSNumber(value: Double(cameraLayer.pitch))

            let center = CLLocation(latitude: CLLocationDegrees(cameraLayer.centerCoordinateLatitude),
                                    longitude: CLLocationDegrees(cameraLayer.centerCoordinateLongitude))

            let updatedCameraOptions = CameraOptions(__center: center,
                                                     padding: padding,
                                                     anchor: anchor,
                                                     zoom: zoom,
                                                     bearing: bearing,
                                                     pitch: pitch)

            try! map.jumpTo(forCamera: updatedCameraOptions)
            delegate?.cameraViewManipulated(for: self)
        }
    }
}

public extension EdgeInsets {
    func toUIEdgeInsetsValue() -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(top),
                            left: CGFloat(left),
                            bottom: CGFloat(bottom),
                            right: CGFloat(right))
    }
}

public extension UIEdgeInsets {
    func toMBXEdgeInsetsValue() -> EdgeInsets {
        return EdgeInsets(top: Double(top),
                          left: Double(left),
                          bottom: Double(bottom),
                          right: Double(right))
    }
}
