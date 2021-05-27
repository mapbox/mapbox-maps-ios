import Turf
@_implementationOnly import MapboxCommon_Private

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

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

    /**
     :nodoc:
     Moves a `layer` to a new layer position in the style.
     - Parameter layerId: The layer to move
     - Parameter position: The new position to move the layer to

     - Throws: `StyleError` on failure, or `NSError` with a _domain of "com.mapbox.bindgen"
     */
    public func _moveLayer(withId id: String, to position: LayerPosition) throws {
        let properties = try layerProperties(for: id)
        try removeLayer(withId: id)
        try addLayer(with: properties, layerPosition: position)
    }

    /**
     Gets a `layer` from the map
     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: StyleError or type conversion errors
     */
    public func layer<T: Layer>(withId id: String) throws -> T {
        // swiftlint:disable force_cast
        return try _layer(withId: id, type: T.self) as! T
        // swiftlint:enable force_cast
    }

    /**
     Gets a `layer` from the map.

     This function is useful if you do not know the concrete type of the layer
     you are fetching, or don't need to know for your situation.

     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: StyleError or type conversion errors
     */
    public func _layer(withId id: String, type: Layer.Type) throws -> Layer {
        // Get the layer properties from the map
        let properties = try layerProperties(for: id)
        return try type.init(jsonObject: properties)
    }

    /// Updates a layer that exists in the style already
    ///
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    ///
    /// - Throws: StyleError or type conversion errors
    public func updateLayer<T: Layer>(withId id: String, update: (inout T) throws -> Void) throws {
        var layer: T = try self.layer(withId: id)

        // Call closure to update the retrieved layer
        try update(&layer)

        let value = try layer.jsonObject()

        // Apply the changes to the layer properties to the style
        try setLayerProperties(for: id, properties: value)
    }

    // MARK: - Layer properties

    /// Gets the value of style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The value of the property in the layer with layerId.
    public func layerProperty(for layerId: String, property: String) -> Any {
        return _layerProperty(for: layerId, property: property).value
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
     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type`.
     - Throws: StyleError or type conversion errors
     */
    public func source<T: Source>(withId id: String) throws -> T {
        // swiftlint:disable force_cast
        return try _source(withId: id, type: T.self) as! T
        // swiftlint:enable force_cast
    }

    /**
     Retrieves a source from the map

     This function is useful if you do not know the concrete type of the source
     you are fetching, or don't need to know for your situation.

     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type`.
     - Throws: StyleError or type conversion errors
     */
    public func _source(withId id: String, type: Source.Type) throws  -> Source {
        // Get the source properties for a given identifier
        let sourceProps = try sourceProperties(for: id)
        let source = try type.init(jsonObject: sourceProps)
        return source
    }

    /// Gets the value of style source property.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - property: Style source property name.
    ///
    /// - Returns: The value of the property in the source with sourceId.
    public func sourceProperty(for sourceId: String, property: String) -> Any {
        return _sourceProperty(for: sourceId, property: property).value
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

        let geoJSONDictionary = try GeoJSONManager.dictionaryFrom(geoJSON)
        try setSourceProperty(for: id, property: "data", value: geoJSONDictionary as Any)
    }

    // MARK: - Light

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> Any {
        return _lightProperty(property).value
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
        return _terrainProperty(property).value
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

    public func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    public func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        return try handleExpected {
            return styleManager.addStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition?.corePosition)
        }
    }

    public func removeLayer(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleLayer(forLayerId: id)
        }
    }

    public func layerExists(withId id: String) -> Bool {
        return styleManager.styleLayerExists(forLayerId: id)
    }

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

    public func _layerProperty(for layerId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleLayerProperty(forLayerId: layerId, property: property)
    }

    public func setLayerProperty(for layerId: String, property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleLayerPropertyForLayerId(layerId, property: property, value: value)
        }
    }

    public static func _layerPropertyDefaultValue(for layerType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleLayerPropertyDefaultValue(forLayerType: layerType, property: property)
    }

    public func layerProperties(for layerId: String) throws -> [String: Any] {
        return try handleExpected {
            return styleManager.getStyleLayerProperties(forLayerId: layerId)
        }
    }

    public func setLayerProperties(for layerId: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleLayerPropertiesForLayerId(layerId, properties: properties)
        }
    }

    // MARK: - Sources

    public func addSource(withId id: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.addStyleSource(forSourceId: id, properties: properties)
        }
    }

    public func removeSource(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleSource(forSourceId: id)
        }
    }

    public func sourceExists(withId id: String) -> Bool {
        return styleManager.styleSourceExists(forSourceId: id)
    }

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

    public func _sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleSourceProperty(forSourceId: sourceId, property: property)
    }

    public func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        }
    }

    public func sourceProperties(for sourceId: String) throws -> [String: Any] {
        return try handleExpected {
            return styleManager.getStyleSourceProperties(forSourceId: sourceId)
        }
    }

    public func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties)
        }
    }

    public static func _sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    // MARK: - Image source

    public func updateImageSource(withId id: String, image: UIImage) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw TypeConversionError.unexpectedType
        }

        return try handleExpected {
            return styleManager.updateStyleImageSourceImage(forSourceId: id, image: mbmImage)
        }
    }

    // MARK: - Style images

    public func addImage(_ image: UIImage, id: String, sdf: Bool = false, stretchX: [ImageStretches] = [], stretchY: [ImageStretches] = [], content: ImageContent? = nil) throws {
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

    public func removeImage(withId id: String) throws {
        return try handleExpected {
            return styleManager.removeStyleImage(forImageId: id)
        }
    }

    public func image(withId id: String) -> UIImage? {
        guard let mbmImage = styleManager.getStyleImage(forImageId: id) else {
            return nil
        }

        return UIImage(mbxImage: mbmImage)
    }

    // MARK: - Style

    public func setLight(properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleLightForProperties(properties)
        }
    }

    public func _lightProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleLightProperty(forProperty: property)
    }

    public func setLightProperty(_ property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleLightPropertyForProperty(property, value: value)
        }
    }

    // MARK: - Terrain

    public func setTerrain(properties: [String: Any]) throws {
        return try handleExpected {
            return styleManager.setStyleTerrainForProperties(properties)
        }
    }

    public func _terrainProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleTerrainProperty(forProperty: property)
    }

    public func setTerrainProperty(_ property: String, value: Any) throws {
        return try handleExpected {
            return styleManager.setStyleTerrainPropertyForProperty(property, value: value)
        }
    }

    // MARK: - Custom geometry

    public func addCustomGeometrySource(withId id: String, options: CustomGeometrySourceOptions) throws {
        return try handleExpected {
            return styleManager.addStyleCustomGeometrySource(forSourceId: id, options: options)
        }
    }

    public func _setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Turf.Feature]) throws {
        let mbxFeatures = features.compactMap { Feature($0) }
        return try handleExpected {
            return styleManager.setStyleCustomGeometrySourceTileDataForSourceId(sourceId, tileId: tileId, featureCollection: mbxFeatures)
        }
    }

    public func invalidateCustomGeometrySourceTile(forSourceId sourceId: String, tileId: CanonicalTileID) throws {
        return try handleExpected {
            return styleManager.invalidateStyleCustomGeometrySourceTile(forSourceId: sourceId, tileId: tileId)
        }
    }

    public func invalidateCustomGeometrySourceRegion(forSourceId sourceId: String, bounds: CoordinateBounds) throws {
        return try handleExpected {
            return styleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId: sourceId, bounds: bounds)
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
