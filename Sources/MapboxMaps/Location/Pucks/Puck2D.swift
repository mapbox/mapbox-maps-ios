import UIKit
import MapboxCoreMaps
import MapboxCommon

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

    // MARK: Initializers
    internal init(puckStyle: PuckStyle, locationSupportableMapView: LocationSupportableMapView, configuration: Puck2DConfiguration) {
        self.puckStyle = puckStyle
        self.locationSupportableMapView = locationSupportableMapView
        self.configuration = configuration
    }

    // MARK: Protocol Implementation
    internal func updateLocation(location: Location) {
        if let locationIndicatorLayer = self.locationIndicatorLayer,
           let style = locationSupportableMapView?.style {

            let newLocation: [Double] = [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.internalLocation.altitude
            ]

            var bearing: Double = 0.0
            if let latestBearing = location.heading {
                bearing = latestBearing.trueHeading
            }

            let expectedValueLocation = try! style.styleManager.setStyleLayerPropertyForLayerId(locationIndicatorLayer.id,
                                                                                                property: "location",
                                                                                                value: newLocation)
            let expectedValueBearing = try! style.styleManager.setStyleLayerPropertyForLayerId(locationIndicatorLayer.id,
                                                                                               property: "bearing",
                                                                                               value: bearing)

            if expectedValueLocation.isError() {
                try! Log.error(forMessage: "Error when updating location in location indicator layer: \(String(describing: expectedValueLocation.error))", category: "Location")
            }

            if expectedValueBearing.isError() {
                try! Log.error(forMessage: "Error when updating location in location indicator layer: \(String(describing: expectedValueBearing.error))", category: "Location")
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
                try! Log.error(forMessage: "Error when creating location indicator layer: \(error)", category: "Location")
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
              let style = locationSupportableMapView?.style
        else { return }

        let removeLayerResult = style.removeStyleLayer(forLayerId: locationIndicatorLayer.id)

        if case .failure(let layerError) = removeLayerResult {
            try! Log.error(forMessage: "Error when removing location indicator layer: \(layerError)", category: "Location")
        }

        self.locationIndicatorLayer = nil
    }
}

// MARK: Layer Creation Functions

private extension Puck2D {
    // swiftlint:disable:next cyclomatic_complexity
    func createPreciseLocationIndicatorLayer(location: Location) throws {
        guard let style = locationSupportableMapView?.style else { return }

        _ = style.removeStyleLayer(forLayerId: "approximate-puck")
        // Call customizationHandler to allow developers to granularly modify the layer

        // Add images to sprite sheet
        guard let topImage = configuration.resolvedTopImage, let bearingImage = configuration.resolvedBearingImage else {
            return
        }
        if case let .failure(imageError) = style.setStyleImage(image: topImage, with: "locationIndicatorLayerTopImage", scale: 44.0) {
            throw imageError
        }
        if case let .failure(imageError) = style.setStyleImage(image: bearingImage, with: "locationIndicatorLayerBearingImage", scale: 44.0) {
            throw imageError
        }

        if let validShadowImage = configuration.shadowImage {
            let setStyleImageResultInner = style.setStyleImage(image: validShadowImage, with: "locationIndicatorLayerShadowImage", scale: 44.0)
            if case let .failure(imageError) = setStyleImageResultInner {
                throw imageError
            }
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        var layout = LocationIndicatorLayer.Layout()
        layout.topImage = .constant(ResolvedImage.name("locationIndicatorLayerTopImage"))
        layout.bearingImage = .constant(ResolvedImage.name("locationIndicatorLayerBearingImage"))

        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.internalLocation.altitude
        ])
        paint.locationTransition = StyleTransition(duration: 0, delay: 0)
        paint.topImageSize = configuration.resolvedScale
        paint.bearingImageSize = configuration.resolvedScale
        paint.shadowImageSize = configuration.resolvedScale
        paint.accuracyRadius = .constant(location.horizontalAccuracy)

        paint.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
        paint.bearingTransition = StyleTransition(duration: 0, delay: 0)
        paint.accuracyRadiusColor = .constant(ColorRepresentable(color: UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        paint.accuracyRadiusBorderColor = .constant(ColorRepresentable(color: .lightGray))

        layer.paint = paint

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }

        locationIndicatorLayer = layer
    }

    func createApproximateLocationIndicatorLayer(location: Location) throws {
        guard let style = locationSupportableMapView?.style else { return }
        // TODO: Handle removal of precise indicator properly.
        _ = style.removeStyleLayer(forLayerId: "puck")

        // Create Layer
        var layer = LocationIndicatorLayer(id: "approximate-puck")

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([
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
        paint.accuracyRadius = .expression(exp)

        paint.accuracyRadiusColor = .constant(ColorRepresentable(color: UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        paint.accuracyRadiusBorderColor = .constant(ColorRepresentable(color: .lightGray))
        layer.paint = paint

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }
        locationIndicatorLayer = layer
    }
}
