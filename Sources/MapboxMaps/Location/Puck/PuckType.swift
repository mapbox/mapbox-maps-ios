import UIKit

/// Represents the different types of pucks
public enum PuckType: Equatable {
    /// A 2-dimensional puck. Optionally provide `Puck2DConfiguration` to configure the puck's appearance.
    case puck2D(Puck2DConfiguration = Puck2DConfiguration())

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

public struct Puck2DConfiguration: Equatable, Sendable {

    /// The configuration parameters for sonar-like pulsing circle animation shown around the 2D puck.
    public struct Pulsing: Equatable, Sendable {
        public static let `default` = Pulsing()

        // swiftlint:disable nesting
        /// Circle radius configuration for the pulsing circle animation.
        public enum Radius: Equatable, Sendable {
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

    /// Location puck pulsing configuration is pulsing on the map.
    public var pulsing: Pulsing?

    /// Flag determining if the horizontal accuracy ring should be shown arround the `Puck`. default value is false
    public var showsAccuracyRing: Bool

    /// The color of the accuracy ring.
    public var accuracyRingColor: UIColor

    /// The color of the accuracy ring border.
    public var accuracyRingBorderColor: UIColor

    /// The ``Slot`` where to put puck layers.
    ///
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// Defines relative position of the puck layer.
    public var layerPosition: LayerPosition?

    /// Initialize a `Puck2D` object with a top image, bearing image, shadow image, scale, opacity and accuracy ring visibility.
    /// - Parameters:
    ///   - topImage: The image to use as the top layer for the location indicator.
    ///   - bearingImage: The image used as the middle of the location indicator.
    ///   - shadowImage: The image that acts as a background of the location indicator.
    ///   - scale: The size of the images, as a scale factor applied to the size of the specified image.
    ///   - pulsing: The configuration parameters for sonar-like pulsing circle animation shown around the 2D puck.
    ///   - showsAccuracyRing: Indicates whether the location accurary ring should be shown.
    ///   - opacity: The opacity of the entire location indicator.
    public init(
        topImage: UIImage? = nil,
        bearingImage: UIImage? = nil,
        shadowImage: UIImage? = nil,
        scale: Value<Double>? = nil,
        pulsing: Pulsing? = nil,
        showsAccuracyRing: Bool = false,
        opacity: Double = 1
    ) {
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
    ///   - layerPosition: Specifies the position at which a layer will be added.
    public init(
        topImage: UIImage? = nil,
        bearingImage: UIImage? = nil,
        shadowImage: UIImage? = nil,
        scale: Value<Double>? = nil,
        showsAccuracyRing: Bool = false,
        accuracyRingColor: UIColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3),
        accuracyRingBorderColor: UIColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3),
        opacity: Double = 1,
        layerPosition: LayerPosition? = nil
    ) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
        self.showsAccuracyRing = showsAccuracyRing
        self.accuracyRingColor = accuracyRingColor
        self.accuracyRingBorderColor = accuracyRingBorderColor
        self.opacity = opacity
        self.layerPosition = layerPosition
    }

    /// Create a Puck2DConfiguration instance with or without an arrow bearing image. Default without the arrow bearing image.
    public static func makeDefault(showBearing: Bool = false) -> Puck2DConfiguration {
        return Puck2DConfiguration(
            topImage: UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!,
            bearingImage: showBearing ? .bearingImage.value : nil,
            shadowImage: UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }
}

public struct Puck3DConfiguration: Equatable, Sendable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// The opacity of the model used as the location puck
    public var modelOpacity: Value<Double>?

    /// Enable/disable shadow casting for the puck model
    ///
    ///  - Note: Shadows may impose extra performance costs and lead to extra rendering.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var modelCastShadows: Value<Bool>?

    /// Enable/disable shadow receiving for the puck model
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var modelReceiveShadows: Value<Bool>?

    /// Defines scaling mode. Only applies to location-indicator type layers. Default to ``ModelScaleMode/viewport``.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var modelScaleMode: Value<ModelScaleMode>?

    /// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var modelElevationReference: Value<ModelElevationReference>?

    /// Strength of the emission.
    ///
    /// There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. windows).
    ///
    /// Default value is 1.
    public var modelEmissiveStrength: Value<Double>?

    /// The ``Slot`` where to put puck layers.
    ///
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// Defines relative position of the puck layer.
    public var layerPosition: LayerPosition?

    /// Initialize a `Puck3DConfiguration` with a model, scale and rotation.
    /// - Parameters:
    ///   - model: The `gltf` model to use for the puck.
    ///   - modelScale: The amount to scale the model by.
    ///   - modelRotation: The rotation of the model in euler angles `[lon, lat, z]`.
    ///   - modelOpacity: The opacity of the model used as the location puck
    ///   - layerPosition: Defines relative position of the puck layer.
    public init(
        model: Model,
        modelScale: Value<[Double]>? = nil,
        modelRotation: Value<[Double]>? = nil,
        modelOpacity: Value<Double>? = nil,
        layerPosition: LayerPosition? = nil
    ) {
        self.init(
            model: model,
            modelScale: modelScale,
            modelRotation: modelRotation,
            modelOpacity: modelOpacity,
            modelCastShadows: nil,
            layerPosition: layerPosition)
    }

    /// Initialize a `Puck3DConfiguration` with a model, scale, rotation and an parameter to control shadow casting.
    /// - Parameters:
    ///   - model: The `gltf` model to use for the puck.
    ///   - modelScale: The amount to scale the model by.
    ///   - modelRotation: The rotation of the model in euler angles `[lon, lat, z]`.
    ///   - modelOpacity: The opacity of the model used as the location puck
    ///   - modelCastShadows: Enable/disable shadow casting for the puck model
    ///   - modelReceiveShadows: Enable/disable shadow receiving for the puck model
    ///   - modelScaleMode: Defines scaling mode. Only applies to location-indicator type layers.
    ///   - modelEmissiveStrength: Strength of the light emission.
    ///   - layerPosition: Defines relative position of the puck layer.
    @_documentation(visibility: public)
    @_spi(Experimental) public init(
        model: Model,
        modelScale: Value<[Double]>? = nil,
        modelRotation: Value<[Double]>? = nil,
        modelOpacity: Value<Double>? = nil,
        modelCastShadows: Value<Bool>? = nil,
        modelReceiveShadows: Value<Bool>? = nil,
        modelScaleMode: Value<ModelScaleMode>? = nil,
        modelEmissiveStrength: Value<Double> = .constant(1),
        layerPosition: LayerPosition? = nil
    ) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
        self.modelOpacity = modelOpacity
        self.modelCastShadows = modelCastShadows
        self.modelReceiveShadows = modelReceiveShadows
        self.modelScaleMode = modelScaleMode ?? .constant(.viewport)
        self.modelEmissiveStrength = modelEmissiveStrength
        self.layerPosition = layerPosition
    }
}

private extension UIImage {
    static let bearingImage = Ref {
        makeBearingImage(size: CGSize(width: 22, height: 22))
    }.weaklyCached()

    private static func makeBearingImage(size: CGSize) -> UIImage {
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
}
