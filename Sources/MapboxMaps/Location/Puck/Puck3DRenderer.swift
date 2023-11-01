@_implementationOnly import MapboxCommon_Private

internal final class Puck3DRenderer: Puck3DRendererProtocol {
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
                try? style.removeLayer(withId: Self.layerID)
                try? style.removeSource(withId: Self.sourceID)
                onceConfigurationUpdated.reset()
            }
        }
    }

    // The change in this properties will be handled in the next render call (renderingData update).
    // TODO: Those properties should come as part of rendering data.
    var puckBearing: PuckBearing = .heading
    var puckBearingEnabled: Bool = false
    var configuration: Puck3DConfiguration {
        didSet {
            onceConfigurationUpdated.reset(if: configuration != oldValue)
        }
    }

    private let style: StyleProtocol
    private let renderingData: Signal<PuckRenderingData>
    private var onceConfigurationUpdated = Once()

    private var cancelables = Set<AnyCancelable>()

    internal init(configuration: Puck3DConfiguration,
                  style: StyleProtocol,
                  renderingData: Signal<PuckRenderingData>) {
        self.configuration = configuration
        self.style = style
        self.renderingData = renderingData
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
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

        do {
            // update or create the source
            if style.sourceExists(withId: Self.sourceID) {
                try style.setSourceProperties(for: Self.sourceID, properties: source.jsonObject())
            } else {
                try style.addSource(source)
            }
        } catch {
            Log.error(forMessage: "Failed to update Puck3D Source properties, \(error)")
        }

        var modelLayer = ModelLayer(id: Self.layerID, source: Self.sourceID)
        modelLayer.modelScale = configuration.modelScale
        modelLayer.modelType = .constant(.locationIndicator)
        modelLayer.modelRotation = configuration.modelRotation
        modelLayer.modelOpacity = configuration.modelOpacity
        modelLayer.modelCastShadows = configuration.modelCastShadows
        modelLayer.modelReceiveShadows = configuration.modelReceiveShadows
        modelLayer.modelScaleMode = configuration.modelScaleMode
        modelLayer.modelEmissiveStrength = configuration.modelEmissiveStrength

        do {
            // create the layer if needed
            if !style.layerExists(withId: Self.layerID) {
                try style.addPersistentLayer(modelLayer, layerPosition: nil)
            } else {
                try onceConfigurationUpdated {
                    var properties = try modelLayer.allStyleProperties()
                    properties.removeValue(forKey: "id")
                    properties.removeValue(forKey: "type")
                    properties.removeValue(forKey: "source")
                    try style.setLayerProperties(for: Self.layerID, properties: properties)
                }
            }
        } catch {
            Log.error(forMessage: "Failed to update Puck3D Layer properties, \(error)")
        }
    }
}
