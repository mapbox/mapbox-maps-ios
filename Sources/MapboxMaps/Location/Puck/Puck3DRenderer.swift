@_implementationOnly import MapboxCommon_Private

final class Puck3DRenderer: PuckRenderer {
    var state: PuckRendererState? {
        didSet {
            do {
                if let state, state != oldValue {
                    startRendering(newState: state, oldState: oldValue)
                }
                if state == nil {
                    stopRendering()
                }
            }
        }
    }

    private let style: StyleProtocol

    init(style: StyleProtocol) {
        self.style = style
    }

    private func stopRendering() {
        try? style.removeLayer(withId: Self.layerID)
        try? style.removeSource(withId: Self.sourceID)
    }

    private func startRendering(newState: PuckRendererState, oldState: PuckRendererState?) {
        updateSourceModel(newState: newState, oldState: oldState)
        updateLayer(newState: newState, oldState: oldState)
    }

    private func updateSourceModel(newState: PuckRendererState, oldState: PuckRendererState?) {
        guard let newConfiguration = newState.configuration else {
            return
        }

        var model = newConfiguration.model
        model.position = [newState.coordinate.longitude, newState.coordinate.latitude]

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

        if newState.locationOptions.puckBearingEnabled {
            switch newState.locationOptions.puckBearing {
            case .heading:
                if let validHeadingDirection = newState.heading?.direction {
                    model.orientation?[2] += validHeadingDirection
                }
            case .course:
                if let validCourseDirection = newState.bearing {
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
    }

    private func updateLayer(newState: PuckRendererState, oldState: PuckRendererState?) {
        guard let newConfiguration = newState.configuration,
              newConfiguration != oldState?.configuration else {
            return
        }

        var modelLayer = ModelLayer(id: Self.layerID, source: Self.sourceID)
        modelLayer.modelScale = newConfiguration.modelScale
        modelLayer.modelType = .constant(.locationIndicator)
        modelLayer.modelRotation = newConfiguration.modelRotation
        modelLayer.modelOpacity = newConfiguration.modelOpacity
        modelLayer.modelCastShadows = newConfiguration.modelCastShadows
        modelLayer.modelReceiveShadows = newConfiguration.modelReceiveShadows
        modelLayer.modelScaleMode = newConfiguration.modelScaleMode
        modelLayer.modelEmissiveStrength = newConfiguration.modelEmissiveStrength

        do {
            // create the layer if needed
            if !style.layerExists(withId: Self.layerID) {
                try style.addPersistentLayer(modelLayer, layerPosition: nil)
            } else {
                var properties = try modelLayer.allStyleProperties()
                properties.removeValue(forKey: "id")
                properties.removeValue(forKey: "type")
                properties.removeValue(forKey: "source")
                try style.setLayerProperties(for: Self.layerID, properties: properties)
            }
        } catch {
            Log.error(forMessage: "Failed to update Puck3D Layer properties, \(error)")
        }
    }
}

private extension PuckRendererState {
    var configuration: Puck3DConfiguration? {
        guard case let .puck3D(configuration) = locationOptions.puckType else {
            return nil
        }
        return configuration
    }
}

private extension Puck3DRenderer {
    static let sourceID = "puck-model-source"
    static let layerID = "puck-model-layer"
}
