@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

//swiftlint:disable file_length
public class Style {

    public private(set) weak var styleManager: StyleManager!

    internal init(with styleManager: StyleManager) {
        self.styleManager = styleManager

        if let uri = StyleURI(rawValue: styleManager.getStyleURI()) {
            self.uri = uri
        }
    }

    // MARK: - Layers

    /// Adds a `layer` to the map
    ///
    /// - Parameters:
    ///   - layer: The layer to apply on the map
    ///   - layerPosition: Position at which to add the map.
    ///
    /// - Throws: StyleError or type conversion errors
    public func addLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        // Attempt to encode the provided layer into JSON and apply it to the map
        let layerJSON = try layer.jsonObject()
        try addLayer(with: layerJSON, layerPosition: layerPosition)
    }

    /// Adds a  persistent `layer` to the map
    /// Persistent layers are valid across style changes.
    ///
    /// - Parameters:
    ///   - layer: The layer to apply on the map
    ///   - layerPosition: Position at which to add the map.
    ///
    /// - Throws: StyleError or type conversion errors
    internal func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        // Attempt to encode the provided layer into JSON and apply it to the map
        let layerJSON = try layer.jsonObject()
        try addPersistentLayer(with: layerJSON, layerPosition: layerPosition)
    }

    /**
     Moves a `layer` to a new layer position in the style.
     - Parameter layerId: The layer to move
     - Parameter position: The new position to move the layer to

     - Throws: `StyleError` on failure, or `NSError` with a _domain of "com.mapbox.bindgen"
     */
    public func moveLayer(withId id: String, to position: LayerPosition) throws {
        let properties = try layerProperties(for: id)
        let isPersistent = try isPersistentLayer(id: id)
        try removeLayer(withId: id)

        if isPersistent {
            try addPersistentLayer(with: properties, layerPosition: position)
        } else {
            try addLayer(with: properties, layerPosition: position)
        }
    }

    /**
     Gets a `layer` from the map
     - Parameter id: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: StyleError or type conversion errors
     */
    public func layer<T>(withId id: String, type: T.Type) throws -> T where T: Layer {
        let properties = try layerProperties(for: id)
        return try type.init(jsonObject: properties)
    }

    /**
     Gets a `layer` from the map.

     This function is useful if you do not know the concrete type of the layer
     you are fetching, or don't need to know for your situation.

     - Parameter layerID: The id of the layer to be fetched

     - Returns: The fully formed `layer` object.
     - Throws: Type conversion errors
     */
    public func layer(withId id: String) throws -> Layer {
        // Get the layer properties from the map
        let properties = try layerProperties(for: id)

        guard let typeString = properties["type"] as? String,
              let type = LayerType(rawValue: typeString) else {
            throw TypeConversionError.invalidObject
        }

        return try type.layerType.init(jsonObject: properties)
    }

    /// Updates a layer that exists in the style already
    ///
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    ///
    /// - Throws: StyleError or type conversion errors
    public func updateLayer<T>(withId id: String,
                               type: T.Type,
                               update: (inout T) throws -> Void) throws where T: Layer {
        var layer = try self.layer(withId: id, type: T.self)

        // Call closure to update the retrieved layer
        try update(&layer)
        let value = try layer.jsonObject()

        // Apply the changes to the layer properties to the style
        try setLayerProperties(for: id, properties: value)
    }

    // MARK: - Sources

    /**
     Adds a source to the map
     - Parameter source: The source to add to the map.
     - Parameter identifier: A unique source identifier.

     - Throws: StyleError or type conversion errors
     */
    public func addSource(_ source: Source, id: String) throws {
        let sourceDictionary = try source.jsonObject()
        try addSource(withId: id, properties: sourceDictionary)
    }

    /**
     Retrieves a source from the map
     - Parameter id: The id of the source to retrieve
     - Parameter type: The type of the source

     - Returns: The fully formed `source` object of type equal to `type`.
     - Throws: StyleError or type conversion errors
     */
    public func source<T>(withId id: String, type: T.Type) throws -> T where T: Source {
        let sourceProps = try sourceProperties(for: id)
        return try type.init(jsonObject: sourceProps)
    }

    /**
     Retrieves a source from the map

     This function is useful if you do not know the concrete type of the source
     you are fetching, or don't need to know for your situation.

     - Parameter id: The id of the source to retrieve.
     - Returns: The fully formed `source` object.
     - Throws: Type conversion errors.
     */
    public func source(withId id: String) throws  -> Source {
        // Get the source properties for a given identifier
        let sourceProps = try sourceProperties(for: id)

        guard let typeString = sourceProps["type"] as? String,
              let type = SourceType(rawValue: typeString) else {
            throw TypeConversionError.invalidObject
        }
        return try type.sourceType.init(jsonObject: sourceProps)
    }

    /// Updates the `data` property of a given `GeoJSONSource` with a new value
    /// conforming to the `GeoJSONObject` protocol.
    ///
    /// - Parameters:
    ///   - id: The identifier representing the GeoJSON source.
    ///   - geoJSON: The new GeoJSON to be associated with the source data. i.e.
    ///   a feature or feature collection.
    ///
    /// - Throws: StyleError or type conversion errors
    ///
    /// - Attention: This method is only effective with sources of `GeoJSONSource`
    /// type, and cannot be used to update other source types.
    public func updateGeoJSONSource<T: GeoJSONObject>(withId id: String, geoJSON: T) throws {
        guard let sourceInfo = allSourceIdentifiers.first(where: { $0.id == id }),
              sourceInfo.type == .geoJson else {
            fatalError("updateGeoJSONSource: Source with id '\(id)' is not a GeoJSONSource.")
        }
        let data = try JSONEncoder().encode(geoJSON)
        let value = try JSONSerialization.jsonObject(with: data)
        try setSourceProperty(for: id, property: "data", value: value)
    }

    // MARK: - Light

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> Any {
        return lightProperty(property).value
    }

    // MARK: - Terrain

    /// Sets a terrain on the style
    ///
    /// - Parameter terrain: The `Terrain` that should be rendered
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setTerrain(_ terrain: Terrain) throws {
        let terrainData = try JSONEncoder().encode(terrain)
        guard let terrainDictionary = try JSONSerialization.jsonObject(with: terrainData) as? [String: Any] else {
            throw TypeConversionError.unexpectedType
        }

        try setTerrain(properties: terrainDictionary)
    }

    /// Gets the value of a style terrain property.
    ///
    /// - Parameter property: Style terrain property name.
    ///
    /// - Returns: Style terrain property value.
    public func terrainProperty(_ property: String) -> Any {
        return terrainProperty(property).value
    }

    // MARK: - Conversion helpers

    private func handleExpected(closure: () -> (Expected<AnyObject, AnyObject>)) throws {
        let expected = closure()

        if expected.isError() {
            // swiftlint:disable force_cast
            throw StyleError(message: expected.error as! String)
            // swiftlint:enable force_cast
        }
    }

    private func handleExpected<T>(closure: () -> (Expected<AnyObject, AnyObject>)) throws -> T {
        let expected = closure()

        if expected.isError() {
            // swiftlint:disable force_cast
            throw StyleError(message: expected.error as! String)
            // swiftlint:enable force_cast
        }

        guard let result = expected.value as? T else {
            assertionFailure("Unexpected type mismatch. Type: \(String(describing: expected.value)) expect \(T.self)")
            throw TypeConversionError.unexpectedType
        }

        return result
    }
}

// MARK: - StyleManagerProtocol -

// See `StyleManagerProtocol` for documentation for the following APIs
extension Style: StyleManagerProtocol {
    public var isLoaded: Bool {
        return styleManager.isStyleLoaded()
    }

    public var uri: StyleURI? {
        get {
            let uriString = styleManager.getStyleURI()

            // A "nil" style is returned as an empty string
            if uriString.isEmpty {
                return nil
            }

            guard let styleURI = StyleURI(rawValue: uriString) else {
                fatalError()
            }
            return styleURI
        }
        set {
            if let uriString = newValue?.rawValue {
                styleManager.setStyleURIForUri(uriString)
            }
        }
    }

    public var JSON: String {
        get {
            styleManager.getStyleJSON()
        }
        set {
            styleManager.setStyleJSONForJson(newValue)
        }
    }

    public var defaultCamera: CameraOptions {
        return CameraOptions(styleManager.getStyleDefaultCamera())
    }

    public var transition: TransitionOptions {
        get {
            styleManager.getStyleTransition()
        }
        set {
            styleManager.setStyleTransitionFor(newValue)
        }
    }

    // MARK: - Layers

    /// Adds a new style layer given its JSON properties
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#layers
    ///
    /// - Parameters:
    ///   - properties: A JSON dictionary of style layer properties.
    ///   - layerPosition: If not empty, the new layer will be positioned according
    ///         to `LayerPosition` parameters.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Adds a new persistent style layer given its JSON properties
    ///
    /// Persistent style layers remain valid across style reloads.
    ///
    /// - Parameters:
    ///   - properties: A JSON dictionary of style layer properties
    ///   - layerPosition: If not empty, the new layer will be positioned according
    ///         to `LayerPosition` parameters.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful
    @_spi(Experimental) public func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addPersistentStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Returns `true` if the id passed in is associated to a persistent layer
    /// - Parameter id: The layer identifier to test
    @_spi(Experimental) public func isPersistentLayer(id: String) throws -> Bool {
        return try handleExpected {
            return styleManager.isStyleLayerPersistent(forLayerId: id)
        }
    }

    /// Adds a new persistent style custom layer.
    ///
    /// Persistent style layers are valid across style reloads.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#layers
    ///
    /// - Parameters:
    ///   - id: Style layer id.
    ///   - layerHost: Style custom layer host.
    ///   - layerPosition: If not empty, the new layer will be positioned according
    ///         to `LayerPosition` parameters.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    @_spi(Experimental) public func addPersistentCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addPersistentStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Adds a new style custom layer.
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#layers
    ///
    /// - Parameters:
    ///   - id: Style layer id.
    ///   - layerHost: Style custom layer host.
    ///   - layerPosition: If not empty, the new layer will be positioned according
    ///         to `LayerPosition` parameters.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Removes an existing style layer
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - Parameter id: Identifier of the style layer to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func removeLayer(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleLayer(forLayerId: id)
        }
    }

    /// Checks whether a given style layer exists.
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - Parameter id: Style layer identifier.
    ///
    /// - Returns: `true` if the given style layer exists, `false` otherwise.
    public func layerExists(withId id: String) -> Bool {
        return styleManager.styleLayerExists(forLayerId: id)
    }

    /// The ordered list of the current style layers' identifiers and types
    public var allLayerIdentifiers: [LayerInfo] {
        return styleManager.getStyleLayers().compactMap { info in
            guard let layerType = LayerType(rawValue: info.type) else {
                assertionFailure("Failed to create LayerType from \(info.type)")
                return nil
            }
            return LayerInfo(id: info.id, type: layerType)
        }
    }

    // MARK: - Layer Properties

    /// Gets the value of style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The value of the property in the layer with layerId.
    public func layerPropertyValue(for layerId: String, property: String) -> Any {
        return layerProperty(for: layerId, property: property).value
    }

    /// Gets the value of style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The value of the property in the layer with layerId.
    public func layerProperty(for layerId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleLayerProperty(forLayerId: layerId, property: property)
    }

    /// Sets a JSON value to a style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///   - value: Style layer property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setLayerProperty(for layerId: String, property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleLayerPropertyForLayerId(layerId, property: property, value: value)
        }
    }

    /// Gets the default value of style layer property.
    ///
    /// - Parameters:
    ///   - layerType: Style layer type.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The default value of the property for the layers with type layerType.
    public static func layerPropertyDefaultValue(for layerType: LayerType, property: String) -> StylePropertyValue {
        return StyleManager.getStyleLayerPropertyDefaultValue(forLayerType: layerType.rawValue, property: property)
    }

    /// Gets the properties for a style layer.
    ///
    /// - Parameter layerId: layer id.
    ///
    /// - Returns:
    ///     JSON dictionary representing the layer properties
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func layerProperties(for layerId: String) throws -> [String: Any] {
        return try handleExpected {
            return styleManager.getStyleLayerProperties(forLayerId: layerId)
        }
    }

    /// Sets style layer properties.
    ///
    /// This method can be used to perform batch update for a style layer properties.
    /// The structure of a provided `properties` value must conform to the
    /// [format for a corresponding layer type](https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/).
    ///
    /// Modification of a [layer identifier](https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#id)
    /// and/or [layer type](https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#type)
    /// is not allowed.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - properties: JSON dictionary representing the updated layer properties.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setLayerProperties(for layerId: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleLayerPropertiesForLayerId(layerId, properties: properties)
        }
    }

    // MARK: - Sources

    /// Adds a new style source.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#sources
    ///
    /// - Parameters:
    ///   - sourceId: An identifier for the style source.
    ///   - properties: A JSON dictionary of style source properties.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addSource(withId id: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.addStyleSource(forSourceId: id, properties: properties)
        }
    }

    /// Removes an existing style source.
    ///
    /// - Parameter sourceId: Identifier of the style source to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func removeSource(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleSource(forSourceId: id)
        }
    }

    /// Checks whether a given style source exists.
    ///
    /// - Parameter sourceId: Style source identifier.
    ///
    /// - Returns: `true` if the given source exists, `false` otherwise.
    public func sourceExists(withId id: String) -> Bool {
        return styleManager.styleSourceExists(forSourceId: id)
    }

    /// The ordered list of the current style sources' identifiers and types
    public var allSourceIdentifiers: [SourceInfo] {
        return styleManager.getStyleSources().compactMap { info in
            guard let sourceType = SourceType(rawValue: info.type) else {
                assertionFailure("Failed to create SourceType from \(info.type)")
                return nil
            }
            return SourceInfo(id: info.id, type: sourceType)
        }
    }

    // MARK: - Source properties

    /// Gets the value of style source property.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - property: Style source property name.
    ///
    /// - Returns: The value of the property in the source with sourceId.
    public func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleSourceProperty(forSourceId: sourceId, property: property)
    }

    /// Sets a value to a style source property.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - property: Style source property name.
    ///   - value: Style source property value (JSON value)
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        }
    }

    /// Gets style source properties.
    ///
    /// - Parameter sourceId: Style source identifier
    ///
    /// - Returns:
    ///     JSON dictionary representing the layer properties
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func sourceProperties(for sourceId: String) throws -> [String: Any] {
        return try handleExpected {
            return styleManager.getStyleSourceProperties(forSourceId: sourceId)
        }
    }

    /// Sets style source properties.
    ///
    /// This method can be used to perform batch update for a style source properties.
    /// The structure of a provided `properties` value must conform to the
    /// [format](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/) for a
    /// corresponding source type. Modification of a [source type](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#type)
    /// is not allowed.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - properties: A JSON dictionary of Style source properties
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties)
        }
    }

    /// Gets the default value of style source property.
    ///
    /// - Parameters:
    ///   - sourceType: Style source type.
    ///   - property: Style source property name.
    ///
    /// - Returns:
    ///     The default value for the named property for the sources with type sourceType.
    public static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    // MARK: - Image source

    /// Updates the image of an image style source.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#sources-image
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - image: UIImage
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func updateImageSource(withId id: String, image: UIImage) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw TypeConversionError.unexpectedType
        }

        return try handleExpected {
            return styleManager.updateStyleImageSourceImage(forSourceId: id, image: mbmImage)
        }
    }

    // MARK: - Style images

    // MARK: Style images

    /// Adds an image to be used in the style.
    ///
    /// This API can also be used for
    /// updating an image. If the image id was already added, it gets replaced
    /// by the new image.
    ///
    /// The image can be used in
    /// [`icon-image`](https://www.mapbox.com/mapbox-gl-js/style-spec/#layout-symbol-icon-image),
    /// [`fill-pattern`](https://www.mapbox.com/mapbox-gl-js/style-spec/#paint-fill-fill-pattern), and
    /// [`line-pattern`](https://www.mapbox.com/mapbox-gl-js/style-spec/#paint-line-line-pattern).
    ///
    /// - Parameters:
    ///   - image: Image to add.
    ///   - id: ID of the image.
    ///   - sdf: Option to treat whether image is SDF(signed distance field) or not.
    ///         Setting this to `true` allows template images to be recolored. The
    ///         default value is `false`.
    ///   - stretchX: An array of two-element arrays, consisting of two numbers
    ///         that represent the from position and the to position of areas
    ///         that can be stretched horizontally.
    ///   - stretchY: An array of two-element arrays, consisting of two numbers
    ///         that represent the from position and the to position of areas
    ///         that can be stretched vertically.
    ///   - content: An array of four numbers, with the first two specifying the
    ///         left, top corner, and the last two specifying the right, bottom
    ///         corner. If present, and if the icon uses icon-text-fit, the
    ///         symbol's text will be fit inside the content box.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addImage(_ image: UIImage,
                         id: String,
                         sdf: Bool = false,
                         stretchX: [ImageStretches],
                         stretchY: [ImageStretches],
                         content: ImageContent? = nil) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw TypeConversionError.unexpectedType
        }

        return try handleExpected {
            return styleManager.addStyleImage(forImageId: id,
                                              scale: Float(image.scale),
                                              image: mbmImage,
                                              sdf: sdf,
                                              stretchX: stretchX,
                                              stretchY: stretchY,
                                              content: content)
        }
    }

    /// Removes an image from the style.
    ///
    /// - Parameter id: ID of the image to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func removeImage(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleImage(forImageId: id)
        }
    }

    /// Get an image from the style.
    ///
    /// - Parameter id: ID of the image.
    ///
    /// - Returns: UIImage representing the data associated with the given ID,
    ///     or nil if no image is associated with that ID.
    public func image(withId id: String) -> UIImage? {
        guard let mbmImage = styleManager.getStyleImage(forImageId: id) else {
            return nil
        }

        return UIImage(mbxImage: mbmImage)
    }

    // MARK: - Style

    /// Sets the style global light source properties.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#light
    ///
    /// - Parameter properties: A dictionary of style light properties values,
    ///     with their names as key.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setLight(properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleLightForProperties(properties)
        }
    }

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleLightProperty(forProperty: property)
    }

    /// Sets a value to the style light property.
    ///
    /// - Parameters:
    ///   - property: Style light property name.
    ///   - value: Style light property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setLightProperty(_ property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleLightPropertyForProperty(property, value: value)
        }
    }

    // MARK: - Terrain

    /// Sets the style global terrain source properties.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#terrain
    ///
    /// - Parameter properties: A dictionary of style terrain properties values,
    ///     with their names as key.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setTerrain(properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleTerrainForProperties(properties)
        }
    }

    /// Gets the value of a style terrain property.
    ///
    /// - Parameter property: Style terrain property name.
    ///
    /// - Returns: Style terrain property value.
    public func terrainProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleTerrainProperty(forProperty: property)
    }

    /// Sets a value to the named style terrain property.
    ///
    /// - Parameters:
    ///   - property: Style terrain property name.
    ///   - value: Style terrain property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setTerrainProperty(_ property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleTerrainPropertyForProperty(property, value: value)
        }
    }

    // MARK: - Custom geometry

    /// Adds a custom geometry to be used in the style.
    ///
    /// To add the data, implement the fetchTileFunction callback in the options
    /// and call `setCustomGeometrySourceTileData`.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - options: Settings for the custom geometry
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addCustomGeometrySource(withId id: String, options: CustomGeometrySourceOptions) throws {
        return try handleExpected {
            return styleManager.addStyleCustomGeometrySource(forSourceId: id, options: options)
        }
    }

    /// Set tile data of a custom geometry.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - tileId: Identifier of the tile
    ///   - features: An array of features to add
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Turf.Feature]) throws {
        let mbxFeatures = features.compactMap { MapboxCommon.Feature($0) }
        return try handleExpected {
            return styleManager.setStyleCustomGeometrySourceTileDataForSourceId(sourceId, tileId: tileId, featureCollection: mbxFeatures)
        }
    }

    /// Invalidate tile for provided custom geometry source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - tileId: Identifier of the tile
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func invalidateCustomGeometrySourceTile(forSourceId sourceId: String, tileId: CanonicalTileID) throws {
        return try handleExpected {
            return styleManager.invalidateStyleCustomGeometrySourceTile(forSourceId: sourceId, tileId: tileId)
        }
    }

    /// Invalidate region for provided custom geometry source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - bounds: Coordinate bounds.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func invalidateCustomGeometrySourceRegion(forSourceId sourceId: String, bounds: CoordinateBounds) throws {
        return try handleExpected {
            return styleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId: sourceId, bounds: bounds)
        }
    }
}

// MARK: - Attribution -

extension Style {
    internal func sourceAttributions() -> [String] {
        return allSourceIdentifiers.compactMap {
            sourceProperty(for: $0.id, property: "attribution").value as? String
        }
    }
}

// MARK: - StyleTransition -

/**
 The transition property for a layer.
 A transition property controls timing for the interpolation between a
 transitionable style property's previous value and new value.
 */
public struct StyleTransition: Codable {

    internal enum CodingKeys: String, CodingKey {
        case duration
        case delay
    }

    /// Time allotted for transitions to complete in seconds.
    public var duration: TimeInterval = 0

    /// Length of time before a transition begins in seconds.
    public var delay: TimeInterval = 0

    /// Initiralizer for `StyleTransition`
    /// - Parameters:
    ///   - duration: Time for transition in seconds.
    ///   - delay: Time before transition begins in seconds.
    public init(duration: TimeInterval, delay: TimeInterval) {
        self.duration = duration
        self.delay = delay
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        duration = try container.decode(Double.self, forKey: .duration) / 1000
        delay = try container.decode(Double.self, forKey: .delay) / 1000
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(duration * 1000, forKey: .duration)
        try container.encode(delay * 1000, forKey: .delay)
    }
}
