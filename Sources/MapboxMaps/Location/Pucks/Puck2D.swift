import UIKit
import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private

public struct Puck2DConfiguration: Equatable {

    /// Image to use as the top of the location indicator.
    public var topImage: UIImage?

    /// Image to use as the middle of the location indicator.
    public var bearingImage: UIImage?

    /// Image to use as the background of the location indicator.
    public var shadowImage: UIImage?

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public var scale: Value<Double>?

    /// Flag determining if the horizontal accuracy ring should be shown arround the ``Puck``. default value is false
    public var showsAccuracyRing: Bool

    /// Initialize a ``Puck2D`` object with a top image, bearing image, shadow image, scale, and accuracy ring visibility.
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
                showsAccuracyRing: Bool = false) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
        self.showsAccuracyRing = showsAccuracyRing
    }

    internal var resolvedTopImage: UIImage? {
        topImage ?? UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)
    }

    internal var resolvedBearingImage: UIImage? {
        bearingImage ?? UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)
    }

    internal var resolvedScale: Value<Double> {
        scale ?? .constant(1.0)
    }
}

internal class Puck2D: Puck {

    // MARK: Properties
    internal var locationIndicatorLayer: LocationIndicatorLayer?
    internal var configuration: Puck2DConfiguration

    // MARK: Protocol Properties
    internal var puckStyle: PuckStyle
    internal var puckBearingSource: PuckBearingSource

    internal weak var style: LocationStyleProtocol?

    // MARK: Initializers
    internal init(puckStyle: PuckStyle,
                  puckBearingSource: PuckBearingSource,
                  style: LocationStyleProtocol,
                  configuration: Puck2DConfiguration) {
        self.puckStyle = puckStyle
        self.puckBearingSource = puckBearingSource
        self.style = style
        self.configuration = configuration
    }

    deinit {
        removePuck()
    }

    // MARK: Protocol Implementation
    internal func updateLocation(location: Location) {
        if let locationIndicatorLayer = locationIndicatorLayer,
           let style = style {

            let newLocation: [Double] = [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.internalLocation.altitude
            ]

            var bearing: Double = 0.0
            switch puckBearingSource {
            case .heading:
                if let latestBearing = location.heading {
                    bearing = latestBearing.trueHeading
                }
            case .course:
                bearing = location.course
            }

            do {
                try style.setLayerProperties(for: locationIndicatorLayer.id,
                                             properties: [
                                                "location": newLocation,
                                                "bearing": bearing
                                             ])
            } catch {
                Log.error(forMessage: "Error when updating location/bearing in location indicator layer: \(error)", category: "Location")
            }
        } else {
            updateStyle(puckStyle: puckStyle, location: location)
        }
    }

    internal func updateStyle(puckStyle: PuckStyle, location: Location) {
        self.puckStyle = puckStyle

        let setupLocationIndicatorLayer = { [weak self] in
            guard let self = self else { return }
            self.removePuck()
            do {
                switch self.puckStyle {
                case .precise:
                    try self.createPreciseLocationIndicatorLayer(location: location)
                case .approximate:
                    try self.createApproximateLocationIndicatorLayer(location: location)
                }
            } catch {
                Log.error(forMessage: "Error when creating location indicator layer: \(error)", category: "Location")
            }
        }

        // Setup the location  indicator layer initially
        setupLocationIndicatorLayer()

        // Ensure that location indicator layer gets reloaded whenever the style is changed
    }

    internal func removePuck() {
        guard let locationIndicatorLayer = self.locationIndicatorLayer,
              let style = style else {
            return
        }

        do {
            try style.removeLayer(withId: locationIndicatorLayer.id)
        } catch {
            Log.error(forMessage: "Error when removing location indicator layer: \(error)", category: "Location")
        }

        self.locationIndicatorLayer = nil
    }
}

// MARK: Layer Creation Functions

internal extension Puck2D {
    func createPreciseLocationIndicatorLayer(location: Location) throws {
        guard let style = style else {
            Log.warning(forMessage: "Puck2D.createPreciseLocationIndicatorLayer - Style does not exit.", category: "Location")
            return
        }

        if style.layerExists(withId: "approximate-puck") {
            try style.removeLayer(withId: "approximate-puck")
        }
        // Call customizationHandler to allow developers to granularly modify the layer

        // Add images to sprite sheet
        guard let topImage = configuration.resolvedTopImage, let bearingImage = configuration.resolvedBearingImage else {
            return
        }

        try style.addImage(topImage,
                           id: "locationIndicatorLayerTopImage",
                           sdf: false,
                           stretchX: [],
                           stretchY: [],
                           content: nil)
        try style.addImage(bearingImage,
                           id: "locationIndicatorLayerBearingImage",
                           sdf: false,
                           stretchX: [],
                           stretchY: [],
                           content: nil)

        if let validShadowImage = configuration.shadowImage {
            try style.addImage(validShadowImage,
                               id: "locationIndicatorLayerShadowImage",
                               sdf: false,
                               stretchX: [],
                               stretchY: [],
                               content: nil)
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")
        layer.topImage = .constant(ResolvedImage.name("locationIndicatorLayerTopImage"))
        layer.bearingImage = .constant(ResolvedImage.name("locationIndicatorLayerBearingImage"))
        layer.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.internalLocation.altitude
        ])
        layer.locationTransition = StyleTransition(duration: 0.5, delay: 0)
        layer.topImageSize = configuration.resolvedScale
        layer.bearingImageSize = configuration.resolvedScale
        layer.shadowImageSize = configuration.resolvedScale
        layer.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
        layer.bearingTransition = StyleTransition(duration: 0, delay: 0)

        // Horizontal accuracy ring is an optional visual for the 2D Puck
        if configuration.showsAccuracyRing {
            layer.accuracyRadius = .constant(location.horizontalAccuracy)
            layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
            layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        }

        // Add layer to style
        try style.addPersistentLayer(layer, layerPosition: nil)

        locationIndicatorLayer = layer
    }

    func createApproximateLocationIndicatorLayer(location: Location) throws {
        guard let style = style else {
            Log.warning(forMessage: "Puck2D.createApproximateLocationIndicatorLayer - Style does not exit.", category: "Location")
            return
        }

        if style.layerExists(withId: "puck") {
            try style.removeLayer(withId: "puck")
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "approximate-puck")

        // Create and set Paint property
        layer.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.internalLocation.altitude
        ])
        let exp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            400000
            4
            200000
            8
            5000
        }
        layer.accuracyRadius = .expression(exp)

        layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))

        // Add layer to style
        try style.addPersistentLayer(layer, layerPosition: nil)

        locationIndicatorLayer = layer
    }
}
