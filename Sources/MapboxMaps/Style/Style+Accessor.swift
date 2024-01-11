struct Accessor<T> {
    typealias Action = (T) throws -> Void
    let insert: Action
    let remove: Action
    let update: (T, T) throws -> Void
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
    var layers: Accessor<LayerWrapper>
    var sources: Accessor<SourceWrapper>
    var images: Accessor<StyleImage>
    var terrain: Accessor<Terrain>
    var atmosphere: Accessor<Atmosphere>
    var projection: Accessor<StyleProjection>
}

extension StyleManagerProtocol {
    var accessors: StyleAccessors {
        let styleSourceManager = StyleSourceManager(styleManager: self)
        return StyleAccessors(
            layers: Accessor(
                insert: {
                    let properties = try $0.asLayer.allStyleProperties()
                    try handleExpected {
                        self.addStyleLayer(forProperties: properties, layerPosition: nil)
                    }
                },
                remove: {
                    let layerID = $0.asLayer.id
                    try handleExpected {
                        self.removeStyleLayer(forLayerId: layerID)
                    }
                },
                update: { _, new in
                    let properties = try new.asLayer.jsonObject()
                    try handleExpected {
                        self.setStyleLayerPropertiesForLayerId(
                            new.asLayer.id,
                            properties: properties
                        )
                    }
                },
                isEqual: ==
            ),
            sources: Accessor(
                insert: { try styleSourceManager.addSource($0.asSource) },
                remove: { try styleSourceManager.removeSource(withId: $0.asSource.id) },
                update: { old, new in
                    try SourceWrapper.update(old: old, new: new, styleSourceManager: styleSourceManager)
                },
                isEqual: { _, _ in false }
            ),
            images: Accessor(
                insert: {
                    try addImage($0)
                },
                remove: {
                    let imageId = $0.id
                    try handleExpected {
                        self.removeStyleImage(forImageId: imageId)
                    }
                },
                update: { old, new in
                    try handleExpected {
                        self.removeStyleImage(forImageId: old.id)
                    }
                    try addImage(new)
                },
                isEqual: { _, _ in false }
            ),
            terrain: .property(
                set: {
                    guard let terrainDictionary = try $0.toJSON() as? [String: Any] else {
                        throw TypeConversionError.unexpectedType
                    }
                    try handleExpected {
                        self.setStyleTerrainForProperties(terrainDictionary)
                    }
                },
                 remove: {
                     let properties = NSNull()
                     try handleExpected {
                         self.setStyleTerrainForProperties(properties)
                     }
                 }),
            atmosphere: .property(
                set: {
                    guard let properties = try $0.toJSON() as? [String: Any] else {
                        throw TypeConversionError.unexpectedType
                    }
                    try handleExpected {
                        self.setStyleAtmosphereForProperties(properties)
                    }
                },
                remove: {
                    let properties = NSNull()
                    try handleExpected {
                        self.setStyleAtmosphereForProperties(properties)
                    }
                }),
            projection: .property(
                set: {
                    let properties = try $0.allStyleProperties()
                    try handleExpected {
                        self.setStyleProjectionForProperties(properties)
                    }
                },
                remove: {
                    // default to Mercator as there is no way to remove all projections
                    let properties = NSNull()
                    try handleExpected {
                        self.setStyleProjectionForProperties(properties)
                    }
                }
            )
        )
    }

    private func addImage(_ styleImage: StyleImage) throws {
        let imageProperties = ImageProperties(styleImage: styleImage)
        guard let mbmImage = CoreMapsImage(uiImage: styleImage.image) else {
            throw TypeConversionError.unexpectedType
        }

        try handleExpected {
            self.addStyleImage(
                forImageId: styleImage.id,
                scale: imageProperties.scale,
                image: mbmImage,
                sdf: styleImage.sdf,
                stretchX: [ImageStretches(first: imageProperties.stretchXFirst, second: imageProperties.stretchXSecond)],
                stretchY: [ImageStretches(first: imageProperties.stretchYFirst, second: imageProperties.stretchYSecond)],
                content: imageProperties.contentBox)
        }
    }
}
