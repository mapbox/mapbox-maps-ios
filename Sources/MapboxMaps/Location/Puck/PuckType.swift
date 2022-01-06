import UIKit

/// Represents the different types of pucks
public enum PuckType: Equatable {
    /// A 2-dimensional puck. Optionally provide `Puck2DConfiguration` to configure the puck's appearance.
    case puck2D(Puck2DConfiguration = Puck2DConfiguration())

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

public struct Puck2DConfiguration: Equatable {

    /// Image to use as the top of the location indicator.
    public var topImage: UIImage?

    /// Image to use as the middle of the location indicator.
    public var bearingImage: UIImage?

    /// Whether the bearing image of location puck is shown.
    public var showBearingImage: Bool = false

    /// Image to use as the background of the location indicator.
    public var shadowImage: UIImage?

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public var scale: Value<Double>?

    /// Flag determining if the horizontal accuracy ring should be shown arround the `Puck`. default value is false
    public var showsAccuracyRing: Bool

    /// Initialize a `Puck2D` object with a top image, bearing image, shadow image, scale, and accuracy ring visibility.
    /// - Parameters:
    ///   - topImage: The image to use as the top layer for the location indicator.
    ///   - bearingImage: The image used as the middle of the location indicator.
    ///   - shadowImage: The image that acts as a background of the location indicator.
    ///   - scale: The size of the images, as a scale factor applied to the size of the specified image..
    ///   - showsAccuracyRing: Indicates whether the location accurary ring should be shown.
    public init(topImage: UIImage? = nil,
                bearingImage: UIImage? = nil,
                shadowImage: UIImage? = nil,
                scale: Value<Double>? = nil,
                showsAccuracyRing: Bool = false,
                showBearingImage: Bool = false) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
        self.showsAccuracyRing = showsAccuracyRing
        self.showBearingImage = showBearingImage
    }
}

public struct Puck3DConfiguration: Equatable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Initialize a `Puck3DConfiguration` with a model, scale and rotation.
    /// - Parameters:
    ///   - model: The `gltf` model to use for the puck.
    ///   - modelScale: The amount to scale the model by.
    ///   - modelRotation: The rotation of the model in euler angles `[lon, lat, z]`.
    public init(model: Model, modelScale: Value<[Double]>? = nil, modelRotation: Value<[Double]>? = nil) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
    }
}
