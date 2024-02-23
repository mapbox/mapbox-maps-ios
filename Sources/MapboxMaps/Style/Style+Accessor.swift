struct Accessor<T> {
    let insert: (T) throws -> Void
    let remove: (String?) throws -> Void
    let update: (T?, T) throws -> Void
    let isEqual: (T, T) -> Bool
}

extension Accessor where T: Equatable {
    static func property(set: @escaping (T) throws -> Void, remove: @escaping () throws -> Void) -> Accessor {
        Accessor(
            insert: set,
            remove: { _ in try remove() },
            update: { _, new in try set(new) },
            isEqual: ==
        )
    }
}

struct StyleAccessors {
    var sources: Accessor<SourceWrapper>
    var layers: Accessor<LayerWrapper>
    var images: Accessor<StyleImage>
    var terrain: Accessor<Terrain>
    var atmosphere: Accessor<Atmosphere>
    var light: Accessor<MapStyleModel.Light>
    var projection: Accessor<StyleProjection>

    init(styleManager: StyleManagerProtocol, styleSourceManager: StyleSourceManagerProtocol) {
        sources = StyleAccessors.buildSourceAccessor(styleSourceManager: styleSourceManager)
        layers = StyleAccessors.buildLayerAccessor(styleManager: styleManager)
        images = StyleAccessors.buildImageAccessor(styleManager: styleManager)
        terrain = StyleAccessors.buildTerrainAccessor(styleManager: styleManager)
        atmosphere = StyleAccessors.buildAtmosphereAccessor(styleManager: styleManager)
        light = StyleAccessors.buildLightAccessor(styleManager: styleManager)
        projection = StyleAccessors.buildProjectionAccessor(styleManager: styleManager)
    }

    private static func buildSourceAccessor(styleSourceManager: StyleSourceManagerProtocol) -> Accessor<SourceWrapper> {
        Accessor(
            insert: {
                try styleSourceManager.addSource($0.asSource, dataId: nil)
            },
            remove: { id in
                if let id {
                    try styleSourceManager.removeSource(withId: id)
                }
            },
            update: { old, new in
                if let old {
                    try SourceWrapper.update(old: old, new: new, styleSourceManager: styleSourceManager)
                }
            },
            isEqual: { _, _ in false }
        )
    }

    private static func buildLayerAccessor(styleManager: StyleManagerProtocol) -> Accessor<LayerWrapper> {
        Accessor(
            insert: {
                let properties = try $0.layer.asLayer.allStyleProperties()
                let layerPosition = $0.position?.corePosition
                try handleExpected {
                    styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition)
                }
            },
            remove: { id in
                if let id {
                    try handleExpected {
                        styleManager.removeStyleLayer(forLayerId: id)
                    }
                }
            },
            update: { old, new in
                let properties = try new.layer.asLayer.jsonObject()
                try handleExpected {
                    styleManager.setStyleLayerPropertiesForLayerId(
                        new.layer.asLayer.id,
                        properties: properties
                    )
                }

                if old?.position != new.position,
                let layerPosition = new.position?.corePosition {
                    try handleExpected {
                        styleManager.moveStyleLayer(forLayerId: new.layer.asLayer.id, layerPosition: layerPosition)
                    }
                }
            },
            isEqual: ==
        )
    }

    private static func buildImageAccessor(styleManager: StyleManagerProtocol) -> Accessor<StyleImage> {
        Accessor(
            insert: {
                try StyleAccessors.insertImage(image: $0, styleManager: styleManager)
            },
            remove: { id in
                if let id {
                    try handleExpected {
                        styleManager.removeStyleImage(forImageId: id)
                    }
                }
            },
            update: { old, new in
                if let id = old?.id {
                    try handleExpected {
                        styleManager.removeStyleImage(forImageId: id)
                    }
                }
                try StyleAccessors.insertImage(image: new, styleManager: styleManager)
            },
            isEqual: ==
        )
    }

    private static func buildTerrainAccessor(styleManager: StyleManagerProtocol) -> Accessor<Terrain> {
        .property(
            set: {
                guard let terrainDictionary = try $0.toJSON() as? [String: Any] else {
                    throw TypeConversionError.unexpectedType
                }
                try handleExpected {
                    styleManager.setStyleTerrainForProperties(terrainDictionary)
                }
            },
            remove: {
                let properties = NSNull()
                try handleExpected {
                    styleManager.setStyleTerrainForProperties(properties)
                }
            }
        )
    }

    private static func buildAtmosphereAccessor(styleManager: StyleManagerProtocol) -> Accessor<Atmosphere> {
        .property(
            set: {
                guard let properties = try $0.toJSON() as? [String: Any] else {
                    throw TypeConversionError.unexpectedType
                }
                try handleExpected {
                    styleManager.setStyleAtmosphereForProperties(properties)
                }
            },
            remove: {
                let properties = NSNull()
                try handleExpected {
                    styleManager.setStyleAtmosphereForProperties(properties)
                }
            }
        )
    }

    private static func buildLightAccessor(styleManager: StyleManagerProtocol) -> Accessor<MapStyleModel.Light> {
        .property(
            set: { value in
                guard let properties = try value.styleLightProperties else {
                    throw TypeConversionError.invalidObject
                }

                try handleExpected {
                    styleManager.setStyleLightsForLights(properties)
                }
            },
            remove: {
                let properties = NSNull()
                try handleExpected {
                    styleManager.setStyleLightsForLights(properties)
                }
            }
        )
    }

    private static func buildProjectionAccessor(styleManager: StyleManagerProtocol) -> Accessor<StyleProjection> {
        .property(
            set: {
                let properties = try $0.allStyleProperties()
                try handleExpected {
                    styleManager.setStyleProjectionForProperties(properties)
                }
            },
            remove: {
                let properties = NSNull()
                try handleExpected {
                    styleManager.setStyleProjectionForProperties(properties)
                }
            }
        )
    }

    private static func insertImage(image: StyleImage, styleManager: StyleManagerProtocol) throws {
        let imageProperties = ImageProperties(styleImage: image)
        guard let mbmImage = CoreMapsImage(uiImage: image.image) else {
            throw TypeConversionError.unexpectedType
        }

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
}
