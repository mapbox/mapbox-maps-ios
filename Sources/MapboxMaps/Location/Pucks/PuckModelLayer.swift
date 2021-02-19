import UIKit
import MapboxCoreMaps
import MapboxCommon

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

public struct PuckModelLayerViewModel: Equatable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Initialize a PuckModelLayerViewModel with a model, scale and rotation
    public init(model: Model, modelScale: Value<[Double]>? = nil, modelRotation: Value<[Double]>? = nil) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
    }
}

internal class PuckModelLayer: Puck {

    // MARK: Properties
    internal var puckModelLayerVM: PuckModelLayerViewModel
    internal var modelLayer: ModelLayer
    internal var modelSource: ModelSource
    internal var initialPuckOrientation: [Double]?

    // MARK: Protocol Properties
    internal var puckStyle: PuckStyle
    internal weak var locationSupportableMapView: LocationSupportableMapView?
    public var style: Style!

    // MARK: Initializers
    internal init(currentPuckStyle: PuckStyle, locationSupportableMapView: LocationSupportableMapView, viewModel: PuckModelLayerViewModel) {
        modelLayer = ModelLayer(id: "puck-model-layer")
        modelSource = ModelSource()
        puckModelLayerVM = viewModel
        self.locationSupportableMapView = locationSupportableMapView
        style = locationSupportableMapView.style
        puckStyle = currentPuckStyle
        self.setup()
    }

    internal func setup() {

        modelLayer.source = "puck-model-source"

        // Set the model to the source
        modelSource.models = ["puck-model": puckModelLayerVM.model]
        initialPuckOrientation = puckModelLayerVM.model.orientation


        if let validModelScale = puckModelLayerVM.modelScale {
            modelLayer.paint?.modelScale = validModelScale
        }

        if let validModelRotation = puckModelLayerVM.modelRotation {
            modelLayer.paint?.modelRotation = validModelRotation
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

            let initalOrientation = initialPuckOrientation != nil ? initialPuckOrientation![2] : 0
            orientation[2] = initalOrientation + validDirection
            model.orientation = orientation
        }

        modelSource.models = [key: model]
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
