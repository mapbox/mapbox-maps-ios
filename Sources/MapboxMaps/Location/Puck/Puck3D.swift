@_implementationOnly import MapboxCommon_Private

internal final class Puck3D: Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                interpolatedLocationProducer
                    .observe { [weak self] _ in
                        self?.updateSourceAndLayer()
                        return true
                    }
                    .add(to: cancelables)
                updateSourceAndLayer()
            } else {
                cancelables.cancelAll()
                if style.layerExists(withId: Self.layerID) {
                    try! style.removeLayer(withId: Self.layerID)
                }
                if style.sourceExists(withId: Self.sourceID) {
                    try! style.removeSource(withId: Self.sourceID)
                }
            }
        }
    }

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateSourceAndLayer()
        }
    }

    internal var puckBearingEnabled: Bool = true

    private var mercatorScale: Double = 1.0 {
        didSet {
            try? style.updateLayer(withId: Self.layerID, type: ModelLayer.self, update: updateModelScale(layer:))
        }
    }

    private let configuration: Puck3DConfiguration
    private let style: StyleProtocol
    private let interpolatedLocationProducer: InterpolatedLocationProducerProtocol

    private let cancelables = CancelableContainer()

    private static let sourceID = "puck-model-source"
    private static let layerID = "puck-model-layer"

    internal init(configuration: Puck3DConfiguration,
                  style: StyleProtocol,
                  interpolatedLocationProducer: InterpolatedLocationProducerProtocol) {
        self.configuration = configuration
        self.style = style
        self.interpolatedLocationProducer = interpolatedLocationProducer
    }

    private func updateSourceAndLayer() {
        guard isActive, let location = interpolatedLocationProducer.location else {
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
        if puckBearingEnabled {
            switch puckBearingSource {
            case .heading:
                if let validHeadingDirection = location.heading {
                    model.orientation?[2] += validHeadingDirection
                }
            case .course:
                if let validCourseDirection = location.course {
                    model.orientation?[2] += validCourseDirection
                }
            }
        }
        var source = ModelSource()
        source.models = ["puck-model": model]

        // update or create the source
        if style.sourceExists(withId: Self.sourceID) {
            try! style.setSourceProperties(for: Self.sourceID, properties: source.jsonObject())
        } else {
            try! style.addSource(source, id: Self.sourceID)
        }

        // Mercator scale
        maybeUpdateMercatorScale(at: location.coordinate.latitude)

        // create the layer if needed
        if !style.layerExists(withId: Self.layerID) {
            var modelLayer = ModelLayer(id: Self.layerID)
            modelLayer.source = Self.sourceID
            modelLayer.modelType = .constant(.locationIndicator)
            modelLayer.modelRotation = configuration.modelRotation
            updateModelScale(layer: &modelLayer)
            try! style.addPersistentLayer(modelLayer, layerPosition: nil)
        }
    }

    private func maybeUpdateMercatorScale(at latitude: Double) {
        let validLatitudeRange = -85.051128779806604...85.051128779806604
        // In Mercator projection the scale factor is changed along the meridians as a function of latitude
        // to keep the scale factor equal in all direction: k=sec(latitude), where sec(α) = 1 / cos(α).
        // Here we are inverting the logic, as the 3D puck is using real-world size, and we are revising
        // the appearance to look constant on a mercator projection map.
        let newMercatorScale = cos(latitude.clamped(to: validLatitudeRange) * .pi / 180.0)

        // Threshold to update the mercator scale factor when the latitude changes,
        // so that we don't update the scale expression too frequently and cause performance issues.
        if abs(newMercatorScale - mercatorScale) > 0.01 {
            mercatorScale = newMercatorScale
        }
    }

    private func updateModelScale(layer: inout ModelLayer) {
        let modelScale: Value<[Double]>? = {
            switch configuration.modelScale {
            case .constant(let scales):
                let maxZoom = 22.0
                let minZoom = 0.5
                // To make the 3D puck's size constant across different zoom levels, the 3D puck's size (real world object size)
                // should be exponential to the zoom level.
                // The base of the exponential expression is decided by how the tile pyramid works:
                // at zoom level n, we have 2^(n+1) tiles to cover the earth.
                let exponentialBase = 0.5
                return .expression(
                    Exp(.interpolate) {
                        Exp(.exponential) { exponentialBase }
                        Exp(.zoom)
                        minZoom
                        Exp(.literal) {
                            scales.map { scale -> Double in
                                let modelScale = pow(2.0, maxZoom - minZoom)
                                return modelScale * scale * mercatorScale
                            }
                        }
                        maxZoom
                        Exp(.literal) {
                            scales.map { $0 * mercatorScale }
                        }
                    }
                )

            default: return configuration.modelScale
            }
        }()

        layer.modelScale = modelScale
    }
}
