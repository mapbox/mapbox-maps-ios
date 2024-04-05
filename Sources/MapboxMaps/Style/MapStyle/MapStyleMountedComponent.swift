import os
@_implementationOnly import MapboxCommon_Private

protocol MapStyleMountedComponent {
    func mount(with context: MapStyleNodeContext) throws
    func unmount(with context: MapStyleNodeContext) throws
    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool
    func updateMetadata(with: MapStyleNodeContext)
}

struct MountedLayer<L>: MapStyleMountedComponent where L: Layer, L: Equatable {
    var layer: L
    var position: LayerPosition?

    func mount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "layer insert %s", layer.id)
        let properties = try layer.allStyleProperties()
        let position = position ?? context.lastLayerId.map { .above($0) } ?? context.startLayerPosition

        if let customLayer = layer as? CustomLayer {
            try handleExpected {
                context.managers.style.addStyleCustomLayer(forLayerId: customLayer.id, layerHost: customLayer.renderer, layerPosition: position?.corePosition)
            }
            try handleExpected {
                context.managers.style.setStyleLayerPropertiesForLayerId(layer.id, properties: properties)
            }
        } else {
            try handleExpected {
                context.managers.style.addStyleLayer(forProperties: properties, layerPosition: position?.corePosition)
            }
        }
    }

    func unmount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "layer remove %s", layer.id)
        try handleExpected {
            context.managers.style.removeStyleLayer(forLayerId: layer.id)
        }
    }

    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        guard let old = old as? Self, old.layer.id == layer.id else {
            return false
        }

        if old.layer != layer {
            os_log(.debug, log: .styleDsl, "layer update %s", layer.id)
            let properties = try layer.jsonObject()
            try handleExpected {
                context.managers.style.setStyleLayerPropertiesForLayerId(layer.id, properties: properties)
            }
        }

        if old.position != position, let position = position?.corePosition {
            os_log(.debug, log: .styleDsl, "layer position update %s", layer.id)
            try handleExpected {
                context.managers.style.moveStyleLayer(forLayerId: layer.id, layerPosition: position)
            }
        }

        return true
    }

    func updateMetadata(with context: MapStyleNodeContext) {
        if position == nil {
            context.lastLayerId  = layer.id
        }
    }
}

struct MountedSource<S>: MapStyleMountedComponent where S: Source, S: UpdatableSource {
    var source: S

    func mount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "source insert %s", source.id)
        try context.managers.source.addSource(source, dataId: nil)
    }

    func unmount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "source remove %s", source.id)
        try context.managers.source.removeSourceUnchecked(withId: source.id)
    }

    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        let id = source.id
        guard let old = old as? Self, id == old.source.id else { return false }

        os_log(.debug, log: .styleDsl, "source update %s", id)
        try source.update(from: old.source, with: context.managers.source)

        return true
    }

    func updateMetadata(with: MapStyleNodeContext) {

    }
}

struct MountedImage: MapStyleMountedComponent {
    var image: StyleImage

    func mount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "image insert %s", image.id)
        let imageProperties = ImageProperties(styleImage: image)
        guard let mbmImage = CoreMapsImage(uiImage: image.image) else {
            throw TypeConversionError.unexpectedType
        }

        try handleExpected {
            context.managers.style.addStyleImage(
                forImageId: imageProperties.id,
                scale: imageProperties.scale,
                image: mbmImage,
                sdf: imageProperties.sdf,
                stretchX: [ImageStretches(first: imageProperties.stretchXFirst, second: imageProperties.stretchXSecond)],
                stretchY: [ImageStretches(first: imageProperties.stretchYFirst, second: imageProperties.stretchYSecond)],
                content: imageProperties.contentBox)
        }
    }

    func unmount(with context: MapStyleNodeContext) throws {
        os_log(.debug, log: .styleDsl, "image remove %s", image.id)
        try handleExpected {
            context.managers.style.removeStyleImage(forImageId: image.id)
        }
    }

    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        guard let old = old as? Self, image.id == old.image.id else {
            return false
        }

        if image != old.image {
            // Image with the same id can be re-inserted to update.
            try mount(with: context)
        }
        return true
    }

    func updateMetadata(with: MapStyleNodeContext) {}
}

struct MountedModel: MapStyleMountedComponent {
    var model: Model

    func mount(with context: MapStyleNodeContext) throws {
        guard let id = model.id, let uri = model.uri else { return }
        os_log(.debug, log: .styleDsl, "model insert %s", id)

        try handleExpected {
            context.managers.style.addStyleModel(forModelId: id, modelUri: uri.absoluteString)
        }
    }

    func unmount(with context: MapStyleNodeContext) throws {
        guard let id = model.id else { return }
        os_log(.debug, log: .styleDsl, "model remove %s", id)
        try handleExpected {
            context.managers.style.removeStyleModel(forModelId: id)
        }
    }

    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        guard let old = old as? Self, model.id == old.model.id else {
            return false
        }
        if model != old.model {
            /// Model with the same id can be re-inserted to update.
            try mount(with: context)
        }
        return true
    }

    func updateMetadata(with: MapStyleNodeContext) {}
}

struct MountedUniqueProperty<V>: MapStyleMountedComponent {
    var keyPath: WritableKeyPath<MapStyleUniqueProperties, V?>
    var value: V

    func mount(with context: MapStyleNodeContext) throws {
    }

    func unmount(with context: MapStyleNodeContext) throws {
    }

    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        return false
    }

    func updateMetadata(with context: MapStyleNodeContext) {
        context.uniqueProperties[keyPath: keyPath] = value
    }
}

struct MountedEmpty: MapStyleMountedComponent {
    func mount(with context: MapStyleNodeContext) throws {}
    func unmount(with context: MapStyleNodeContext) throws {}
    func tryUpdate(from old: Any, with context: MapStyleNodeContext) throws -> Bool {
        return false
    }
    func updateMetadata(with: MapStyleNodeContext) {

    }
}

extension OSLog {
    static let styleDsl: OSLog = {
        ProcessInfo.processInfo.environment.keys.contains("MAPBOX_MAPS_STYLE_DSL_LOGS_ENABLED") ?
            OSLog(subsystem: "com.mapbox.maps", category: "style-dsl") : .disabled
    }()
}
