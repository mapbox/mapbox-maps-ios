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
    @_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Puck2D: MapContent, PrimitiveMapContent {
    private var configuration: Puck2DConfiguration
    private var bearing: PuckBearing?

    /// Creates 2D puck.
    @_documentation(visibility: public)
    public init(bearing: PuckBearing? = nil) {
        self.configuration = .makeDefault(showBearing: bearing != nil)
        self.bearing = bearing
    }

    /// The opacity of the entire location indicator.
    @_documentation(visibility: public)
    public func opacity(_ opacity: Double) -> Puck2D {
        copyAssigned(self, \.configuration.opacity, opacity)
    }

    /// Image to use as the top of the location indicator.
    @_documentation(visibility: public)
    public func topImage(_ topImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.topImage, topImage)
    }

    /// Image to use as the middle of the location indicator.
    @_documentation(visibility: public)
    public func bearingImage(_ bearingImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.bearingImage, bearingImage)
    }

    /// Image to use as the background of the location indicator.
    @_documentation(visibility: public)
    public func shadowImage(_ shadowImage: UIImage?) -> Puck2D {
        copyAssigned(self, \.configuration.shadowImage, shadowImage)
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
    @_documentation(visibility: public)
    public func scale(_ scale: Double) -> Puck2D {
        self.scale(.constant(scale))
    }

    /// The size of the images, as a scale factor applied to the size of the specified image.
    @_documentation(visibility: public)
    public func scale(_ scale: Expression) -> Puck2D {
        self.scale(.expression(scale))
    }

    func scale(_ scale: Value<Double>) -> Puck2D {
        copyAssigned(self, \.configuration.scale, scale)
    }

    /// Location puck pulsing configuration is pulsing on the map.
    @_documentation(visibility: public)
    public func pulsing(_ pulsing: Puck2DConfiguration.Pulsing?) -> Puck2D {
        copyAssigned(self, \.configuration.pulsing, pulsing)
    }

    /// Flag determining if the horizontal accuracy ring should be shown around the `Puck`. default value is false
    @_documentation(visibility: public)
    public func showsAccuracyRing(_ showsAccuracyRing: Bool) -> Puck2D {
        copyAssigned(self, \.configuration.showsAccuracyRing, showsAccuracyRing)
    }
    /// The color of the accuracy ring.
    @_documentation(visibility: public)
    public func accuracyRingColor(_ accuracyRingColor: UIColor) -> Puck2D {
        copyAssigned(self, \.configuration.accuracyRingColor, accuracyRingColor)
    }
    /// The color of the accuracy ring border.
    @_documentation(visibility: public)
    public func accuracyRingBorderColor(_ accuracyRingBorderColor: UIColor) -> Puck2D {
        copyAssigned(self, \.configuration.accuracyRingBorderColor, accuracyRingBorderColor)
    }

    /// The ``Slot`` where to put puck layers.
    ///
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public func slot(_ slot: Slot?) -> Puck2D {
        copyAssigned(self, \.configuration.slot, slot)
    }

    @available(iOS 13.0, *)
    func visit(_ node: MapContentNode) {
        let locationOptions = LocationOptions(
            puckType: .puck2D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil
        )
        node.mount(MountedPuck(locationOptions: locationOptions))
    }
}
