import UIKit

/// Represents the different types of pucks
public enum PuckType: Equatable {
    /// A 2-dimensional puck. Optionally provide `Puck2DConfiguration` to configure the puck's appearance.
    case puck2D(Puck2DConfiguration = Puck2DConfiguration())

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

public struct Puck2DConfiguration: Equatable {

    /// The configration parameters for sonar-like pulsing circle animation shown around the 2D puck.
    public struct Pulsing: Equatable {
        public static let `default` = Pulsing()

        // swiftlint:disable nesting
        /// Circle radius configuration for the pulsing circle animation.
        public enum Radius: Equatable {
            /// Pulsing circle should animate with the constant radius.
            case constant(Double)
            /// Pulsing circle animates with the `horizontalAccuracy` form the latest puck location.
            case accuracy
        }
        // swiftlint:enable nesting

        /// Flag determining whether the pulsing circle animation. `true` by default.
        public var isEnabled: Bool

        /// The color of the pulsing circle.
        public var color: UIColor

        /// The radius of the pulsing circle.
        public var radius: Radius

        /// Create a pulsing animation config with a color and radius.
        /// - Parameters:
        ///   - color: The color of the pulsing circle.
        ///   - radius: The radius of the pulsing circle.
        public init(color: UIColor = UIColor(red: 0.29, green: 0.565, blue: 0.886, alpha: 1),
                    radius: Radius = .constant(30)) {
            self.color = color
            self.radius = radius
            self.isEnabled = true
        }
    }

    /// The opacity of the entire location indicator.
    public var opacity: Double

    /// Image to use as the top of the location indicator.
    public var topImage: UIImage?

    /// Image to use as the middle of the location indicator.
    public var bearingImage: UIImage?

    /// Image to use as the background of the location indicator.
    public var shadowImage: UIImage?

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public var scale: Value<Double>?

    // Location puck pulsing configuration is pulsing on the map.
    public var pulsing: Pulsing?

    /// Flag determining if the horizontal accuracy ring should be shown arround the `Puck`. default value is false
    public var showsAccuracyRing: Bool

    /// The color of the accuracy ring.
    public var accuracyRingColor: UIColor

    /// The color of the accuracy ring border.
    public var accuracyRingBorderColor: UIColor

    /// Initialize a `Puck2D` object with a top image, bearing image, shadow image, scale, opacity and accuracy ring visibility.
    /// - Parameters:
    ///   - topImage: The image to use as the top layer for the location indicator.
    ///   - bearingImage: The image used as the middle of the location indicator.
    ///   - shadowImage: The image that acts as a background of the location indicator.
    ///   - scale: The size of the images, as a scale factor applied to the size of the specified image.
    ///   - showsAccuracyRing: Indicates whether the location accurary ring should be shown.
    ///   - opacity: The opacity of the entire location indicator.
    public init(topImage: UIImage? = nil,
                bearingImage: UIImage? = nil,
                shadowImage: UIImage? = nil,
                scale: Value<Double>? = nil,
                pulsing: Pulsing? = nil,
                showsAccuracyRing: Bool = false,
                opacity: Double = 1) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
        self.pulsing = pulsing
        self.showsAccuracyRing = showsAccuracyRing
        self.opacity = opacity
        self.accuracyRingColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)
        self.accuracyRingBorderColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)
    }

    /// Initialize a `Puck2D` object with a top image, bearing image, shadow image, scale, opacity and accuracy ring visibility.
    /// - Parameters:
    ///   - topImage: The image to use as the top layer for the location indicator.
    ///   - bearingImage: The image used as the middle of the location indicator.
    ///   - shadowImage: The image that acts as a background of the location indicator.
    ///   - scale: The size of the images, as a scale factor applied to the size of the specified image..
    ///   - showsAccuracyRing: Indicates whether the location accurary ring should be shown.
    ///   - accuracyRingColor:The color of the accuracy ring.
    ///   - accuracyRingBorderColor: The color of the accuracy ring border.
    ///   - opacity: The opacity of the entire location indicator.
    public init(topImage: UIImage? = nil,
                bearingImage: UIImage? = nil,
                shadowImage: UIImage? = nil,
                scale: Value<Double>? = nil,
                showsAccuracyRing: Bool = false,
                accuracyRingColor: UIColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3),
                accuracyRingBorderColor: UIColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3),
                opacity: Double = 1) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
        self.showsAccuracyRing = showsAccuracyRing
        self.accuracyRingColor = accuracyRingColor
        self.accuracyRingBorderColor = accuracyRingBorderColor
        self.opacity = opacity
    }

    /// Create a Puck2DConfiguration instance with or without an arrow bearing image. Default without the arrow bearing image.
    public static func makeDefault(showBearing: Bool = false) -> Puck2DConfiguration {
        let shadowImage = UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!
        return Puck2DConfiguration(
            topImage: UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!,
            bearingImage: showBearing ? makeBearingImage(size: shadowImage.size) : nil,
            shadowImage: shadowImage)
    }
}

public struct Puck3DConfiguration: Equatable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// The opacity of the model used as the location puck
    public var modelOpacity: Value<Double>?

    /// Initialize a `Puck3DConfiguration` with a model, scale and rotation.
    /// - Parameters:
    ///   - model: The `gltf` model to use for the puck.
    ///   - modelScale: The amount to scale the model by.
    ///   - modelRotation: The rotation of the model in euler angles `[lon, lat, z]`.
    ///   - modelOpacity: The opacity of the model used as the location puck
    public init(model: Model, modelScale: Value<[Double]>? = nil, modelRotation: Value<[Double]>? = nil, modelOpacity: Value<Double>? = nil) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
        self.modelOpacity = modelOpacity
    }
}

private func makeBearingImage(size: CGSize) -> UIImage {
    let gap: CGFloat = 1
    let arcLength: CGFloat = .pi / 4
    assert(arcLength <= .pi / 2)
    let lineWidth: CGFloat = 1

    // The gap determines how much space we put between the circles and the arrow
    // strokes are centered on the path, so half of the width of the line is drawn
    // on either side.
    let radius = size.height / 2 + lineWidth / 2 + gap

    let rightArcPoint = CGPoint(
        x: radius * cos(.pi / 2 - arcLength / 2),
        y: -radius * sin(.pi / 2 - arcLength / 2))

    // The top point is always centered at 0. Calculate its height
    // to produce a right angle between the left and right sides of the arrow
    let topPoint = CGPoint(x: 0, y: rightArcPoint.y - rightArcPoint.x * tan(.pi / 4))

    // Create the path
    let path = UIBezierPath()
    path.move(to: topPoint)
    path.addLine(to: rightArcPoint)
    path.addArc(
        withCenter: .zero,
        radius: radius,
        startAngle: -.pi / 2 + arcLength / 2,
        endAngle: -.pi / 2 - arcLength / 2,
        clockwise: false)
    path.close()
    path.lineWidth = lineWidth
    path.lineJoinStyle = .round

    // Create a rectangle to
    // draw the circles, centering them at the origin
    let outerImageBounds = CGRect(
        origin: CGPoint(
            x: -size.width / 2,
            y: -size.height / 2),
        size: size)

    // Union that rectangle with the bounds
    // of the arrow, also union it with the arrow
    // at 90, 180, and 270 degree rotations to ensure that
    // that the resulting image is square and centered on the origin.
    // finally, pad the image a little to ensure that
    // the arrow's stroke is not cut off.
    let imageBounds = outerImageBounds
        .union(path.bounds)
        .union(path.bounds.applying(.init(rotationAngle: .pi / 2)))
        .union(path.bounds.applying(.init(rotationAngle: .pi)))
        .union(path.bounds.applying(.init(rotationAngle: 3 * .pi / 2)))
        .insetBy(dx: -2, dy: -2)

    // render the image
    return UIGraphicsImageRenderer(bounds: imageBounds).image { _ in
        UIColor.systemBlue.setFill()
        path.fill()
        UIColor.white.setStroke()
        path.stroke()
    }
}
