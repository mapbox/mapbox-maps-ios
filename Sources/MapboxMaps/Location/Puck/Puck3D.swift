@_implementationOnly import MapboxCommon_Private

internal final class Puck3D: NSObject, Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                locationProducer.add(self)
                updateSourceAndLayer()
            } else {
                locationProducer.remove(self)
                if style.layerExists(withId: Self.layerID) {
                    try! style.removeLayer(withId: Self.layerID)
                }
                if style.sourceExists(withId: Self.sourceID) {
                    try! style.removeSource(withId: Self.sourceID)
                }
            }
        }
    }

    #if !os(tvOS)
    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateSourceAndLayer()
        }
    }
    #else
    internal var puckBearingSource: PuckBearingSource = .course {
        didSet {
            updateSourceAndLayer()
        }
    }
    #endif

    private let configuration: Puck3DConfiguration
    private let style: StyleProtocol
    private let locationProducer: LocationProducerProtocol

    private static let sourceID = "puck-model-source"
    private static let layerID = "puck-model-layer"

    internal init(configuration: Puck3DConfiguration,
                  style: StyleProtocol,
                  locationProducer: LocationProducerProtocol) {
        self.configuration = configuration
        self.style = style
        self.locationProducer = locationProducer
        super.init()
    }

    private func updateSourceAndLayer() {
        guard isActive, let location = locationProducer.latestLocation else {
            return
        }

        var model = configuration.model
        model.position = [location.coordinate.longitude, location.coordinate.latitude]
        if model.orientation?.count != 3 {
            if let invalidOrientation = model.orientation {
                Log.warning(
                    forMessage: "Puck3DConfiguration.model.orientation?.count must be 3 or nil. Actual orientation is \(invalidOrientation). Resetting it to [0, 0, 0].",
                    category: "Puck")
            }
            model.orientation = [0, 0, 0]
        }

        switch puckBearingSource {
        #if !os(tvOS)
        case .heading:
            if let validHeadingDirection = location.headingDirection {
                model.orientation?[2] += validHeadingDirection
            }
        #endif
        case .course:
            model.orientation?[2] += location.course
        }

        var source = ModelSource()
        source.models = ["puck-model": model]

        // update or create the source
        if style.sourceExists(withId: Self.sourceID) {
            try! style.setSourceProperties(for: Self.sourceID, properties: source.jsonObject())
        } else {
            try! style.addSource(source, id: Self.sourceID)
        }

        // create the layer if needed
        if !style.layerExists(withId: Self.layerID) {
            var modelLayer = ModelLayer(id: Self.layerID)
            modelLayer.source = Self.sourceID
            assert(modelLayer.paint != nil)
            modelLayer.paint?.modelLayerType = .constant(.locationIndicator)
            modelLayer.paint?.modelScale = configuration.modelScale
            modelLayer.paint?.modelRotation = configuration.modelRotation
            try! style.addPersistentLayer(modelLayer, layerPosition: nil)
        }
    }
}

extension Puck3D: LocationConsumer {
    internal func locationUpdate(newLocation: Location) {
        updateSourceAndLayer()
    }
}
