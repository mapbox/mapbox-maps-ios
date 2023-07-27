@_implementationOnly import MapboxCommon_Private

internal final class Puck3D: Puck {
    private static let sourceID = "puck-model-source"
    internal static let layerID = "puck-model-layer"

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                renderingData.observe { [weak self] data in
                    self?.render(with: data)
                }.store(in: &cancelables)
            } else {
                cancelables.removeAll()
                if style.layerExists(withId: Self.layerID) {
                    try! style.removeLayer(withId: Self.layerID)
                }
                if style.sourceExists(withId: Self.sourceID) {
                    try! style.removeSource(withId: Self.sourceID)
                }
            }
        }
    }

    // The change in this properties will be handled in the next render call (renderingData update).
    // TODO: Those properties should come as part of rendering data.
    internal var puckBearing: PuckBearing = .heading
    internal var puckBearingEnabled: Bool = true

    private let configuration: Puck3DConfiguration
    private let style: StyleProtocol
    private let renderingData: Signal<PuckRenderingData>

    private var cancelables = Set<AnyCancelable>()

    internal init(configuration: Puck3DConfiguration,
                  style: StyleProtocol,
                  renderingData: Signal<PuckRenderingData>) {
        self.configuration = configuration
        self.style = style
        self.renderingData = renderingData
    }

    private func render(with data: PuckRenderingData) {
        guard isActive else { return }

        var model = configuration.model
        model.position = [data.location.coordinate.longitude, data.location.coordinate.latitude]

        model.orientation = model.orientation
            .flatMap { orientation -> [Double]? in
                guard orientation.count == 3 else {
                    Log.warning(
                        forMessage: "Puck3DConfiguration.model.orientation?.count must be 3 or nil. Actual orientation is \(orientation). Resetting it to [0, 0, 0].",
                        category: "Puck")
                    return nil
                }
                return orientation
            } ?? [0, 0, 0]

        if puckBearingEnabled {
            switch puckBearing {
            case .heading:
                if let validHeadingDirection = data.heading?.direction {
                    model.orientation?[2] += validHeadingDirection
                }
            case .course:
                if let validCourseDirection = data.location.bearing {
                    model.orientation?[2] += validCourseDirection
                }
            }
        }
        var source = ModelSource(id: Self.sourceID)
        source.models = ["puck-model": model]

        // update or create the source
        if style.sourceExists(withId: Self.sourceID) {
            try! style.setSourceProperties(for: Self.sourceID, properties: source.jsonObject())
        } else {
            try! style.addSource(source)
        }

        // create the layer if needed
        if !style.layerExists(withId: Self.layerID) {
            var modelLayer = ModelLayer(id: Self.layerID, source: Self.sourceID)
            modelLayer.modelScale = configuration.modelScale
            modelLayer.modelScaleMode = configuration.modelScaleMode
            modelLayer.modelType = .constant(.locationIndicator)
            modelLayer.modelRotation = configuration.modelRotation
            modelLayer.modelOpacity = configuration.modelOpacity
            try! style.addPersistentLayer(modelLayer, layerPosition: nil)
        }
    }
}
