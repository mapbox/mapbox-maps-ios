@_implementationOnly import MapboxCommon_Private

final class Puck3DRenderer: PuckRenderer {
    var state: PuckRendererState<Puck3DConfiguration>? {
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

    private func startRendering(newState: PuckRendererState<Puck3DConfiguration>, oldState: PuckRendererState<Puck3DConfiguration>?) {
        updateSourceModel(newState: newState, oldState: oldState)
        updateLayer(newState: newState, oldState: oldState)
    }

    private func updateSourceModel(newState: PuckRendererState<Puck3DConfiguration>, oldState: PuckRendererState<Puck3DConfiguration>?) {
        var model = newState.configuration.model
        model.position = [newState.coordinate.longitude, newState.coordinate.latitude]

        model.orientation = model.orientation
            .flatMap { orientation -> [Double]? in
                guard orientation.count == 3 else {
                    Log.warning(
                        "Puck3DConfiguration.model.orientation?.count must be 3 or nil. Actual orientation is \(orientation). Resetting it to [0, 0, 0].",
                        category: "Puck")
                    return nil
                }
                return orientation
            } ?? [0, 0, 0]

        if newState.bearingEnabled {
            switch newState.bearingType {
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
            Log.error("Failed to update Puck3D Source properties, \(error)")
        }
    }

    private func updateLayer(newState: PuckRendererState<Puck3DConfiguration>, oldState: PuckRendererState<Puck3DConfiguration>?) {
        let newConfiguration = newState.configuration
        guard newConfiguration != oldState?.configuration else {
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
        modelLayer.modelElevationReference = newConfiguration.modelElevationReference
        modelLayer.slot = newConfiguration.slot

        do {
            // create the layer if needed
            if !style.layerExists(withId: Self.layerID) {
                try style.addPersistentLayer(modelLayer, layerPosition: newConfiguration.layerPosition)
            } else {
                var properties = try modelLayer.allStyleProperties()
                properties.removeValue(forKey: "id")
                properties.removeValue(forKey: "type")
                properties.removeValue(forKey: "source")
                try style.setLayerProperties(for: Self.layerID, properties: properties)
            }

            if oldState?.configuration.layerPosition != newConfiguration.layerPosition {
                try style.moveLayer(withId: Self.layerID, to: newConfiguration.layerPosition ?? .default)
            }
        } catch {
            Log.error("Failed to update Puck3D Layer properties, \(error)")
        }
    }
}

private extension Puck3DRenderer {
    static let sourceID = "puck-model-source"
    static let layerID = "puck-model-layer"
}
