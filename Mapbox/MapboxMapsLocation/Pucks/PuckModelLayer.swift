import UIKit
import MapboxCoreMaps
import MapboxCommon

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

internal class PuckModelLayer: Puck {

    // MARK: Properties
    internal var modelLayer: ModelLayer
    internal var modelSource: ModelSource
    internal var initialPuckOrientation: [Double] = []

    // MARK: Protocol Properties
    internal var puckStyle: PuckStyle
    internal weak var locationSupportableMapView: LocationSupportableMapView?
    public var style: Style!
    
    // Customization hook
    internal var customizationHandler: ((inout ModelLayer, inout ModelSource) -> Void)

    // MARK: Initializers
    internal init(currentPuckStyle: PuckStyle, locationSupportableMapView: LocationSupportableMapView, customizationHandler: @escaping ((inout ModelLayer, inout ModelSource) -> Void)) {
        modelLayer = ModelLayer(id: "puck-model-layer")
        modelSource = ModelSource()
        self.locationSupportableMapView = locationSupportableMapView
        style = locationSupportableMapView.style
        puckStyle = currentPuckStyle
        self.customizationHandler = customizationHandler
        setup()
    }

    internal func setup() {

        modelLayer.source = "puck-model-source"
        customizationHandler(&modelLayer, &modelSource)

        if let model = modelSource.models?.values.first,
           let orientation = model.orientation {
            initialPuckOrientation = orientation
        }

        let addStyle = { [weak self] in
            guard let self = self, let style = self.style else { return }

            self.removePuck()
            style.addSource(source: self.modelSource, identifier: "puck-model-source")
            style.addLayer(layer: self.modelLayer)
        }

        // Do initial setup
        addStyle()

        // Re-apply source, layer if style is ever changed
        self.locationSupportableMapView?.subscribeStyleChangeHandler({ (_) in
            addStyle()
        })
    }

    // MARK: Protocol Implementation
    internal func updateLocation(location: Location) {
        guard let style = style,
              let key = modelSource.models?.keys.first,
              var model = modelSource.models?.values.first else { return }

        model.position = [location.coordinate.longitude, location.coordinate.latitude]
        if var orientation = model.orientation,
           let validDirection = location.headingDirection {
            orientation[2] = initialPuckOrientation[2] + validDirection
            model.orientation = orientation
        }

        modelSource.models = [key : model]
        if let data = try? JSONEncoder().encode([key : model]),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            style.updateSourceProperty(id: "puck-model-source", property: "models", value: jsonDictionary)
        }
    }

    /// This function will take in a new `PuckStyle` and change it accordingly
    func updateStyle(puckStyle: PuckStyle, location: Location) {
        // TODO: Remove this requirement, unnecessary for 3D model layer based pucks
    }

    /// This function will remove the puck from `mapView`
    func removePuck() {
        _ = style.removeStyleLayer(forLayerId: "puck-model-layer")
        try! style.styleManager.removeStyleSource(forSourceId: "puck-model-source")
    }
}
