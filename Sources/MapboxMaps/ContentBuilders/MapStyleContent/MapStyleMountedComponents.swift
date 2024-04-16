import os.log

struct MountedLayer<L>: MapContentMountedComponent where L: Layer, L: Equatable {
    var layer: L
    var customPosition: LayerPosition?

    init(layer: L, customPosition: LayerPosition? = nil) {
        self.layer = layer
        self.customPosition = customPosition
    }

    func mount(with context: MapContentNodeContext) throws {
        let styleManager = context.style.styleManager
        let properties = try layer.allStyleProperties()
        let position = customPosition ?? context.resolveLayerPosition()
        os_log(.debug, log: .contentDSL, "layer %s insert %s", layer.id, position.asString())

        if let customLayer = layer as? CustomLayer {
            try handleExpected {
                styleManager.addStyleCustomLayer(forLayerId: customLayer.id, layerHost: customLayer.renderer, layerPosition: position.corePosition)
            }
            try handleExpected {
                styleManager.setStyleLayerPropertiesForLayerId(layer.id, properties: properties)
            }
        } else {
            try handleExpected {
                styleManager.addStyleLayer(forProperties: properties, layerPosition: position.corePosition)
            }
        }
    }

    func unmount(with context: MapContentNodeContext) throws {
        let styleManager = context.style.styleManager

        guard styleManager.styleLayerExists(forLayerId: layer.id) else {
            return
        }

        os_log(.debug, log: .contentDSL, "layer remove %s", layer.id)

        try handleExpected {
            styleManager.removeStyleLayer(forLayerId: layer.id)
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        let styleManager = context.style.styleManager
        os_log(.debug, log: .contentDSL, "layer try update %s", layer.id)

        guard let old = old as? Self, old.layer.id == layer.id else {
            return false
        }

        guard styleManager.styleLayerExists(forLayerId: layer.id) else {
            return false
        }

        if old.layer != layer {
            os_log(.debug, log: .contentDSL, "layer update properties %s", layer.id)
            let properties = try layer.jsonObject()
            try handleExpected {
                styleManager.setStyleLayerPropertiesForLayerId(layer.id, properties: properties)
            }
        }

        let position = customPosition ?? context.resolveLayerPosition()
        os_log(.debug, log: .contentDSL, "layer %s move to %s", layer.id, position.asString())
        try handleExpected {
            styleManager.moveStyleLayer(forLayerId: layer.id, layerPosition: position.corePosition)
        }

        return true
    }

    func updateMetadata(with context: MapContentNodeContext) {
        if customPosition == nil {
            context.lastLayerId = layer.id
        }
    }
}

struct MountedSource<S>: MapContentMountedComponent where S: Source, S: UpdatableSource {
    var source: S

    func mount(with context: MapContentNodeContext) throws {
        let sourceManager = context.style.sourceManager
        os_log(.debug, log: .contentDSL, "source insert %s", source.id)
        try sourceManager.addSource(source, dataId: nil)
    }

    func unmount(with context: MapContentNodeContext) throws {
        let sourceManager = context.style.sourceManager
        os_log(.debug, log: .contentDSL, "source remove %s", source.id)

        guard sourceManager.sourceExists(withId: source.id) else {
            return
        }

        try sourceManager.removeSourceUnchecked(withId: source.id)
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        os_log(.debug, log: .contentDSL, "source tryUpdate %s", source.id)

        let sourceManager = context.style.sourceManager

        guard let old = old as? Self, source.id == old.source.id else {
            return false
        }

        guard sourceManager.sourceExists(withId: source.id) else {
            return false
        }

        os_log(.debug, log: .contentDSL, "source update %s", source.id)
        try source.update(from: old.source, with: sourceManager)

        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

struct MountedImage: MapContentMountedComponent {
    var image: StyleImage

    func mount(with context: MapContentNodeContext) throws {
        let imageProperties = ImageProperties(styleImage: image)
        let styleManager = context.style.styleManager
        guard let mbmImage = CoreMapsImage(uiImage: image.image) else {
            throw TypeConversionError.unexpectedType
        }

        os_log(.debug, log: .contentDSL, "image insert %s", image.id)

        try handleExpected {
            styleManager.addStyleImage(
                forImageId: imageProperties.id,
                scale: imageProperties.scale,
                image: mbmImage,
                sdf: imageProperties.sdf,
                stretchX: [ImageStretches(first: imageProperties.stretchXFirst, second: imageProperties.stretchXSecond)],
                stretchY: [ImageStretches(first: imageProperties.stretchYFirst, second: imageProperties.stretchYSecond)],
                content: imageProperties.contentBox)
        }
    }

    func unmount(with context: MapContentNodeContext) throws {
        let styleManager = context.style.styleManager
        os_log(.debug, log: .contentDSL, "image remove %s", image.id)

        try handleExpected {
            styleManager.removeStyleImage(forImageId: image.id)
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        let styleManager = context.style.styleManager
        os_log(.debug, log: .contentDSL, "image try update %s", image.id)

        guard let old = old as? Self, image.id == old.image.id else {
            return false
        }

        guard styleManager.hasStyleImage(forImageId: image.id) else {
            return false
        }

        if image != old.image {
            os_log(.debug, log: .contentDSL, "image update %s", image.id)
            // Image with the same id can be re-inserted to update.
            try mount(with: context)
        }
        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

struct MountedModel: MapContentMountedComponent {
    var model: Model

    func mount(with context: MapContentNodeContext) throws {
        guard let id = model.id, let uri = model.uri else { return }
        let styleManager = context.style.styleManager
        os_log(.debug, log: .contentDSL, "model insert %s", id)

        try handleExpected {
            styleManager.addStyleModel(forModelId: id, modelUri: uri.absoluteString)
        }
    }

    func unmount(with context: MapContentNodeContext) throws {
        guard let id = model.id else { return }
        let styleManager = context.style.styleManager
        os_log(.debug, log: .contentDSL, "model remove %s", id)

        try handleExpected {
            styleManager.removeStyleModel(forModelId: id)
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        let styleManager = context.style.styleManager

        guard let old = old as? Self, model.id == old.model.id else {
            return false
        }

        guard let id = model.id, styleManager.hasStyleModel(forModelId: id) else {
            return false
        }

        if model != old.model {
            os_log(.debug, log: .contentDSL, "model update %s", id)
            /// Model with the same id can be re-inserted to update.
            try mount(with: context)
        }
        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

struct MountedUniqueProperty<V>: MapContentMountedComponent {
    var keyPath: WritableKeyPath<MapContentUniqueProperties, V?>
    var value: V

    func mount(with context: MapContentNodeContext) throws {}

    func unmount(with context: MapContentNodeContext) throws {}

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        return false
    }

    func updateMetadata(with context: MapContentNodeContext) {
        context.uniqueProperties[keyPath: keyPath] = value
    }
}

struct MountedEmpty: MapContentMountedComponent {
    func mount(with context: MapContentNodeContext) throws {}
    func unmount(with context: MapContentNodeContext) throws {}
    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        return false
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

extension OSLog {
    static let contentDSL: OSLog = {
        ProcessInfo.processInfo.environment.keys.contains("MAPBOX_MAPS_CONTENT_DSL_LOGS_ENABLED") ?
        OSLog(subsystem: "com.mapbox.maps", category: "content-dsl") : .disabled
    }()
}

private extension LayerPosition {
    func asString() -> String {
        (try? toString()) ?? "<nil>"
    }
}
