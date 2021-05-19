import UIKit
import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

public struct Puck2DConfiguration: Equatable {

    /// Image to use as the top of the location indicator.
    public var topImage: UIImage?

    /// Image to use as the middle of the location indicator.
    public var bearingImage: UIImage?

    /// Image to use as the background of the location indicator.
    public var shadowImage: UIImage?

    /// The size of the images, as a scale factor applied to the size of the specified image.
    public var scale: Value<Double>?

    public init(topImage: UIImage? = nil,
                bearingImage: UIImage? = nil,
                shadowImage: UIImage? = nil,
                scale: Value<Double>? = nil) {
        self.topImage = topImage
        self.bearingImage = bearingImage
        self.shadowImage = shadowImage
        self.scale = scale
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

    internal weak var locationSupportableMapView: LocationSupportableMapView?
    internal weak var style: LocationStyleDelegate?

    // MARK: Initializers
    internal init(puckStyle: PuckStyle,
                  locationSupportableMapView: LocationSupportableMapView,
                  style: LocationStyleDelegate,
                  configuration: Puck2DConfiguration) {
        self.puckStyle = puckStyle
        self.locationSupportableMapView = locationSupportableMapView
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
            if let latestBearing = location.heading {
                bearing = latestBearing.trueHeading
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
        locationSupportableMapView?.subscribeStyleChangeHandler({ _ in
            setupLocationIndicatorLayer()
        })
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

        try style.addImage(topImage, id: "locationIndicatorLayerTopImage")
        try style.addImage(bearingImage, id: "locationIndicatorLayerBearingImage")

        if let validShadowImage = configuration.shadowImage {
            try style.addImage(validShadowImage, id: "locationIndicatorLayerShadowImage")
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
        layer.accuracyRadius = .constant(location.horizontalAccuracy)
        layer.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
        layer.bearingTransition = StyleTransition(duration: 0, delay: 0)
        layer.accuracyRadiusColor = .constant(ColorRepresentable(color: UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        layer.accuracyRadiusBorderColor = .constant(ColorRepresentable(color: .lightGray))

        // Add layer to style
        try style.addLayer(layer)

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

        layer.accuracyRadiusColor = .constant(ColorRepresentable(color: UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        layer.accuracyRadiusBorderColor = .constant(ColorRepresentable(color: .lightGray))

        // Add layer to style
        try style.addLayer(layer)

        locationIndicatorLayer = layer
    }
}
