import Foundation

public struct Puck3DConfiguration: Equatable {

    /// The model to use as the locaiton puck
    public var model: Model

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Initialize a `Puck3DConfiguration` with a model, scale and rotation.
    /// - Parameters:
    ///   - model: The `gltf` model to use for the puck.
    ///   - modelScale: The amount to scale the model by.
    ///   - modelRotation: The rotation of the model in euler angles `[lon, lat, z]`.
    public init(model: Model, modelScale: Value<[Double]>? = nil, modelRotation: Value<[Double]>? = nil) {
        self.model = model
        self.modelScale = modelScale
        self.modelRotation = modelRotation
    }
}

internal final class Puck3D: NSObject, Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                locationSource.add(self)
                updateSourceAndLayer()
            } else {
                locationSource.remove(self)
                if style.layerExists(withId: Self.layerID) {
                    try! style.removeLayer(withId: Self.layerID)
                }
                if style.sourceExists(withId: Self.sourceID) {
                    try! style.removeSource(withId: Self.sourceID)
                }
            }
        }
    }

    // accuracy is not implemented for Puck3D, so
    // this is just here for protocol conformance
    internal var puckAccuracy: PuckAccuracy = .full

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateSourceAndLayer()
        }
    }

    private let configuration: Puck3DConfiguration
    private let style: LocationStyleProtocol
    private let locationSource: LocationSource

    private static let sourceID = "puck-model-source"
    private static let layerID = "puck-model-layer"

    internal init(configuration: Puck3DConfiguration,
                  style: LocationStyleProtocol,
                  locationSource: LocationSource) {
        self.configuration = configuration
        self.style = style
        self.locationSource = locationSource
        super.init()
    }

    private func updateSourceAndLayer() {
        guard isActive, let location = locationSource.latestLocation else {
            return
        }

        var model = configuration.model
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

        if model.orientation == nil || model.orientation?.count != 3 {
            model.orientation = [0, 0, 0]
        }
        model.orientation?[2] += validDirection

        var source = ModelSource()
        source.models = ["puck-model": model]

        if style.sourceExists(withId: Self.sourceID) {
            try! style.setSourceProperties(for: Self.sourceID, properties: source.jsonObject())
        } else {
            try! style.addSource(source, id: Self.sourceID)
        }

        if !style.layerExists(withId: Self.layerID) {
            // create the layer
            var modelLayer = ModelLayer(id: Self.layerID)
            modelLayer.paint?.modelLayerType = .constant(.locationIndicator)
            modelLayer.source = Self.sourceID
            if let validModelScale = configuration.modelScale {
                modelLayer.paint?.modelScale = validModelScale
            }
            if let validModelRotation = configuration.modelRotation {
                modelLayer.paint?.modelRotation = validModelRotation
            }
            try! style.addPersistentLayer(modelLayer, layerPosition: nil)
        }
    }
}

extension Puck3D: LocationConsumer {
    internal func locationUpdate(newLocation: Location) {
        updateSourceAndLayer()
    }
}
