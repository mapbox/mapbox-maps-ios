import UIKit

/// Displays user location via 2D Puck.
///
/// Create the 2D Puck in ``Map-swift.struct`` content.
///
/// ```swift
/// Map {
///     Puck2D(bearing: .heading)
///         .showsAccuracyRing(true)
/// }
/// ```
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct Puck2D: PrimitiveMapContent {
    private var configuration: Puck2DConfiguration
    private var bearing: PuckBearing?

    /// Creates 2D puck.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(bearing: PuckBearing? = nil) {
        self.configuration = .makeDefault(showBearing: bearing != nil)
        self.bearing = bearing
    }

    /// The opacity of the entire location indicator.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func opacity(_ opacity: Double) -> Puck2D {
        copyAssigned(self, \.configuration.opacity, opacity)
    }

    /// Image to use as the top of the location indicator.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func topImage(_ topImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.topImage, topImage)
    }

    /// Image to use as the middle of the location indicator.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func bearingImage(_ bearingImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.bearingImage, bearingImage)
    }

    /// Image to use as the background of the location indicator.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func shadowImage(_ shadowImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.shadowImage, shadowImage)
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func scale(_ scale: Double) -> Puck2D {
        self.scale(.constant(scale))
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func scale(_ scale: Expression) -> Puck2D {
        self.scale(.expression(scale))
    }

    func scale(_ scale: Value<Double>) -> Puck2D {
        copyAssigned(self, \.configuration.scale, scale)
    }

    /// Location puck pulsing configuration is pulsing on the map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func pulsing(_ pulsing: Puck2DConfiguration.Pulsing?) -> Puck2D {
        copyAssigned(self, \.configuration.pulsing, pulsing)
    }

    /// Flag determining if the horizontal accuracy ring should be shown around the `Puck`. default value is false
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func showsAccuracyRing(_ showsAccuracyRing: Bool) -> Puck2D {
        copyAssigned(self, \.configuration.showsAccuracyRing, showsAccuracyRing)
    }
    /// The color of the accuracy ring.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func accuracyRingColor(_ accuracyRingColor: UIColor) -> Puck2D {
        copyAssigned(self, \.configuration.accuracyRingColor, accuracyRingColor)
    }
    /// The color of the accuracy ring border.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func accuracyRingBorderColor(_ accuracyRingBorderColor: UIColor) -> Puck2D {
        copyAssigned(self, \.configuration.accuracyRingBorderColor, accuracyRingBorderColor)
    }

    func _visit(_ visitor: MapContentVisitor) {
        visitor.locationOptions = LocationOptions(
            puckType: .puck2D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil)
    }
}
