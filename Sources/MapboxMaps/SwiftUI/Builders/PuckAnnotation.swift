import UIKit

/// Shows 2D user location puck.
@_spi(Experimental)
public struct PuckAnnotation2D: MapContent {
    private var configuration: Puck2DConfiguration
    private var bearing: PuckBearing?

    /// Creates 2D puck.
    public init(bearing: PuckBearing? = nil) {
        self.configuration = .makeDefault(showBearing: bearing != nil)
        self.bearing = bearing
    }

    /// The opacity of the entire location indicator.
    public func opacity(_ opacity: Double) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.opacity, opacity)
    }

    /// Image to use as the top of the location indicator.
    public func topImage(_ topImage: UIImage?) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.topImage, topImage)
    }

    /// Image to use as the middle of the location indicator.
    public func bearingImage(_ bearingImage: UIImage?) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.bearingImage, bearingImage)
    }

    /// Image to use as the background of the location indicator.
    public func shadowImage(_ shadowImage: UIImage?) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.shadowImage, shadowImage)
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public func scale(_ scale: Double) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.scale, .constant(scale))
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public func scale(_ scale: Expression) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.scale, .expression(scale))
    }

    /// Location puck pulsing configuration is pulsing on the map.
    public func pulsing(_ pulsing: Puck2DConfiguration.Pulsing?) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.pulsing, pulsing)
    }

    /// Flag determining if the horizontal accuracy ring should be shown around the `Puck`. default value is false
    public func showsAccuracyRing(_ showsAccuracyRing: Bool) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.showsAccuracyRing, showsAccuracyRing)
    }
    /// The color of the accuracy ring.
    public func accuracyRingColor(_ accuracyRingColor: UIColor) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.accuracyRingColor, accuracyRingColor)
    }
    /// The color of the accuracy ring border.
    public func accuracyRingBorderColor(_ accuracyRingBorderColor: UIColor) -> PuckAnnotation2D {
        copyAssigned(self, \.configuration.accuracyRingBorderColor, accuracyRingBorderColor)
    }

    func _visit(_ visitor: MapContentVisitor) {
        visitor.locationOptions = LocationOptions(
            puckType: .puck2D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil)
    }
}

/// Shows 3D user location puck.
@_spi(Experimental)
public struct PuckAnnotation3D: MapContent {
    private var configuration: Puck3DConfiguration
    private var bearing: PuckBearing?

    /// Creates puck.
    public init(model: Model, bearing: PuckBearing?) {
        self.configuration = Puck3DConfiguration(model: model)
        self.bearing = bearing
    }

    /// The scale of the model.
    public func modelScale(_ modelScale: [Double]) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelScale, .constant(modelScale))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    public func modelRotation(_ modelRotation: [Double]) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelRotation, .constant(modelRotation))
    }

    /// The opacity of the model used as the location puck
    public func modelOpacity(_ modelOpacity: Double) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelOpacity, .constant(modelOpacity))
    }

    /// Enable/disable shadow casting for the puck model
    public func modelCastShadows(_ modelCastShadows: Bool) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelCastShadows, .constant(modelCastShadows))
    }

    /// Enable/disable shadow receiving for the puck model
    public func modelReceiveShadows(_ modelReceiveShadows: Bool) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelReceiveShadows, .constant(modelReceiveShadows))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers. Defaults to ``ModelScaleMode/viewport``.
    public func modelScaleMode(_ modelScaleMode: ModelScaleMode) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelScaleMode, .constant(modelScaleMode))
    }

    /// The scale of the model.
    public func modelScale(_ modelScale: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelScale, .expression(modelScale))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    public func modelRotation(_ modelRotation: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelRotation, .expression(modelRotation))
    }

    /// The opacity of the model used as the location puck
    public func modelOpacity(_ modelOpacity: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelOpacity, .expression(modelOpacity))
    }

    /// Enable/disable shadow casting for the puck model
    public func modelCastShadows(_ modelCastShadows: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelCastShadows, .expression(modelCastShadows))
    }

    /// Enable/disable shadow receiving for the puck model
    public func modelReceiveShadows(_ modelReceiveShadows: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelReceiveShadows, .expression(modelReceiveShadows))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers. Defaults to ``ModelScaleMode/viewport``.
    public func modelScaleMode(_ modelScaleMode: Expression) -> PuckAnnotation3D {
        copyAssigned(self, \.configuration.modelScaleMode, .expression(modelScaleMode))
    }

    func _visit(_ visitor: MapContentVisitor) {
        visitor.locationOptions = LocationOptions(
            puckType: .puck3D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil)
    }
}

private func copyAssigned<Root, T>(_ s: Root, _ keyPath: WritableKeyPath<Root, T>, _ value: T) -> Root {
    var copy = s
    copy[keyPath: keyPath] = value
    return copy
}

extension PuckAnnotation2D: PrimitiveMapContent {}
extension PuckAnnotation3D: PrimitiveMapContent {}
