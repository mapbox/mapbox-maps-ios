import UIKit
import MapboxCoreMaps
import MapboxCommon

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

internal class PuckLocationIndicatorLayer: Puck {

    // MARK: Properties
    internal var locationIndicatorLayer: LocationIndicatorLayer?

    // MARK: Protocol Properties
    internal var puckStyle: PuckStyle

    internal weak var locationSupportableMapView: LocationSupportableMapView?

    internal var customizationHandler: ((inout LocationIndicatorLayer) -> Void)? = nil

    // MARK: Initializers
    internal init(currentPuckStyle: PuckStyle, locationSupportableMapView: LocationSupportableMapView, customizationHandler: ((inout LocationIndicatorLayer) -> Void)? = nil) {
        self.locationSupportableMapView = locationSupportableMapView
        self.puckStyle = currentPuckStyle
        self.customizationHandler = customizationHandler
    }

    // MARK: Protocol Implementation
    internal func updateLocation(location: Location) {
        if let locationIndicatorLayer = self.locationIndicatorLayer,
           let style = self.locationSupportableMapView?.style {

            let newLocation: [Double] = [location.coordinate.latitude,
                                         location.coordinate.longitude,
                                         location.internalLocation.altitude]

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
            self.updateStyle(puckStyle: self.puckStyle, location: location)
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
                case .headingArrow:
                    try self.createHeadingArrowLocationIndicatorLayer(location: location)
                case .headingBeam:
                    try self.createHeadingBeamLocationIndicatorLayer(location: location)
                case .arrow:
                    try self.createArrowLocationIndicatorLayer(location: location)
                }
            } catch {
                try! Log.error(forMessage: "Error when creating location indicator layer: \(error)", category: "Location")
            }
        }

        // Setup the location  indicator layer initially
        setupLocationIndicatorLayer()

        // Ensure that location indicator layer gets reloaded whenever the style is changed
        self.locationSupportableMapView?.subscribeStyleChangeHandler({ _ in
            setupLocationIndicatorLayer()
        })
    }

    internal func removePuck() {
        guard let locationIndicatorLayer = self.locationIndicatorLayer,
              let style = self.locationSupportableMapView?.style
        else { return }

        let removeLayerResult = style.removeStyleLayer(forLayerId: locationIndicatorLayer.id)

        if case .failure(let layerError) = removeLayerResult {
            try! Log.error(forMessage: "Error when removing location indicator layer: \(layerError)", category: "Location")
        }

        self.locationIndicatorLayer = nil
    }
}

// MARK: Layer Creation Functions
private extension PuckLocationIndicatorLayer {
    func createPreciseLocationIndicatorLayer(location: Location) throws {
        guard let style = self.locationSupportableMapView?.style else { return }

        // Add image to sprite sheet
        guard let triangle = UIImage(named: "triangle") else { return }
        let setStyleImageResult = style.setStyleImage(image: triangle, with: "puck", scale: 50.0)

        if case .failure(let imageError) = setStyleImageResult {
            throw imageError
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        var layout = LocationIndicatorLayer.Layout()
        layout.topImage = .constant(ResolvedImage.name("puck"))
        layout.bearingImage = .constant(ResolvedImage.name("puck"))
        layout.shadowImage = .constant(ResolvedImage.name("puck"))
        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.internalLocation.altitude])
        paint.locationTransition = StyleTransition(duration: 0, delay: 0)
        paint.bearing = .constant(0.0)
        paint.topImageSize = .constant(0.5)
        paint.bearingImageSize = .constant(0.26)
        paint.shadowImageSize = .constant(0.2)
        paint.accuracyRadius = .constant(50.0)

        paint.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
        paint.bearingTransition = StyleTransition(duration: 0, delay: 0)
        paint.accuracyRadiusColor = .constant(ColorRepresentable(color: UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)))
        paint.accuracyRadiusBorderColor = .constant(ColorRepresentable(color: UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4)))
        paint.imagePitchDisplacement = .constant(0.0)
        paint.perspectiveCompensation = .constant(0.9)
        paint.emphasisCircleColor = .constant(ColorRepresentable(color: UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.7, alpha: 0.5)))

        layer.paint = paint

        // Call customizationHandler to allow developers to granularly modify the layer
        self.customizationHandler?(&layer)

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }

        self.locationIndicatorLayer = layer
    }

    func createApproximateLocationIndicatorLayer(location: Location) throws {
        guard let style = self.locationSupportableMapView?.style else { return }

        // Add image to sprite sheet
        guard let triangle = UIImage(named: "triangle") else { return }
        let setStyleImageResult = style.setStyleImage(image: triangle, with: "puck", scale: 50.0)

        if case .failure(let imageError) = setStyleImageResult {
            throw imageError
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        let layout = LocationIndicatorLayer.Layout()
        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.internalLocation.altitude])
        layer.paint = paint

        // Call customizationHandler to allow developers to granularly modify the layer
        self.customizationHandler?(&layer)

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }
        self.locationIndicatorLayer = layer
    }

    func createHeadingArrowLocationIndicatorLayer(location: Location) throws {
        guard let style = self.locationSupportableMapView?.style else { return }

        // Add image to sprite sheet
        guard let triangle = UIImage(named: "triangle") else { return }
        let setStyleImageResult = style.setStyleImage(image: triangle, with: "puck", scale: 50.0)

        if case .failure(let imageError) = setStyleImageResult {
            throw imageError
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        let layout = LocationIndicatorLayer.Layout()
        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.internalLocation.altitude])
        layer.paint = paint

        // Call customizationHandler to allow developers to granularly modify the layer
        self.customizationHandler?(&layer)

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }

        self.locationIndicatorLayer = layer
    }

    func createHeadingBeamLocationIndicatorLayer(location: Location) throws {
        guard let style = self.locationSupportableMapView?.style else { return }

        // Add image to sprite sheet
        guard let triangle = UIImage(named: "triangle") else { return }
        let setStyleImageResult = style.setStyleImage(image: triangle, with: "puck", scale: 50.0)

        if case .failure(let imageError) = setStyleImageResult {
            throw imageError
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        let layout = LocationIndicatorLayer.Layout()
        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.internalLocation.altitude])
        layer.paint = paint

        // Call customizationHandler to allow developers to granularly modify the layer
        self.customizationHandler?(&layer)

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }

        self.locationIndicatorLayer = layer
    }

    func createArrowLocationIndicatorLayer(location: Location) throws {
        guard let style = self.locationSupportableMapView?.style else { return }

        // Add image to sprite sheet
        guard let triangle = UIImage(named: "triangle") else { return }
        let setStyleImageResult = style.setStyleImage(image: triangle, with: "puck", scale: 50.0)

        if case .failure(let imageError) = setStyleImageResult {
            throw imageError
        }

        // Create Layer
        var layer = LocationIndicatorLayer(id: "puck")

        // Create and set Layout property
        let layout = LocationIndicatorLayer.Layout()
        layer.layout = layout

        // Create and set Paint property
        var paint = LocationIndicatorLayer.Paint()
        paint.location = .constant([location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.internalLocation.altitude])
        layer.paint = paint

        // Call customizationHandler to allow developers to granularly modify the layer
        self.customizationHandler?(&layer)

        // Add layer to style
        let addLayerResult = style.addLayer(layer: layer, layerPosition: nil)

        if case .failure(let layerError) = addLayerResult {
            throw layerError
        }

        self.locationIndicatorLayer = layer
    }
}
