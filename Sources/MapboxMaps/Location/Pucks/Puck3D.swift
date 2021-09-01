import UIKit
import MapboxCoreMaps
import MapboxCommon

public struct Puck3DConfiguration: Equatable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Initialize a Puck3DConfiguration with a model, scale and rotation
    public init(model: Model, modelScale: Value<[Double]>? = nil, modelRotation: Value<[Double]>? = nil) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
    }
}

internal class Puck3D: Puck {

    // MARK: Properties
    internal var configuration: Puck3DConfiguration
    internal var modelLayer: ModelLayer
    internal var modelSource: ModelSource
    internal var initialPuckOrientation: [Double]?

    // MARK: Protocol Properties
    internal var puckStyle: PuckStyle
    internal var puckBearingSource: PuckBearingSource
    internal weak var style: LocationStyleProtocol?

    // MARK: Initializers
    internal init(puckStyle: PuckStyle,
                  puckBearingSource: PuckBearingSource,
                  style: LocationStyleProtocol,
                  configuration: Puck3DConfiguration) {
        self.puckStyle = puckStyle
        self.puckBearingSource = puckBearingSource
        self.style = style
        self.configuration = configuration
        modelLayer = ModelLayer(id: "puck-model-layer")
        modelLayer.paint?.modelLayerType = .constant(.locationIndicator)
        modelSource = ModelSource()
        setup()
    }

    deinit {
        removePuck()
    }

    internal func setup() {

        modelLayer.source = "puck-model-source"

        // Set the model to the source
        modelSource.models = ["puck-model": configuration.model]
        initialPuckOrientation = configuration.model.orientation

        if let validModelScale = configuration.modelScale {
            modelLayer.paint?.modelScale = validModelScale
        }

        if let validModelRotation = configuration.modelRotation {
            modelLayer.paint?.modelRotation = validModelRotation
        }

        let addStyle = { [weak self] in
            guard let self = self,
                  let style = self.style else {
                return
            }
            self.removePuck()

            // TODO: On first setup "puck-model does not have a uri"
            try? style.addSource(self.modelSource, id: "puck-model-source")
            try! style._addPersistentLayer(self.modelLayer)
        }

        // Do initial setup
        addStyle()
    }

    // MARK: Protocol Implementation
    internal func updateLocation(location: Location) {
        guard let style = style,
              let key = modelSource.models?.keys.first,
              var model = modelSource.models?.values.first else { return }

        model.position = [location.coordinate.longitude, location.coordinate.latitude]

        var validDirection: Double = 0.0
        switch puckBearingSource {
        case .heading:
            if let validHeadingDirection = location.headingDirection {
                validDirection = validHeadingDirection
            }
        case .course:
            validDirection = location.course
        }

        if var orientation = model.orientation {
            let initalOrientation = initialPuckOrientation != nil ? initialPuckOrientation![2] : 0
            orientation[2] = initalOrientation + validDirection
            model.orientation = orientation
        }

        modelSource.models = [key: model]
        if let data = try? JSONEncoder().encode([key: model]),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            try? style.setSourceProperty(for: "puck-model-source", property: "models", value: jsonDictionary)
        }
    }

    /// This function will take in a new `PuckStyle` and change it accordingly
    func updateStyle(puckStyle: PuckStyle, location: Location) {
        // TODO: Remove this requirement, unnecessary for 3D model layer based pucks
    }

    /// This function will remove the puck from `mapView`
    private func removePuck() {
        guard let style = style,
              style.layerExists(withId: "puck-model-layer") else {
            return
        }

        try! style.removeLayer(withId: "puck-model-layer")
        try! style.removeSource(withId: "puck-model-source")
    }
}
