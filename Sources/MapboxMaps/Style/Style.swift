import Turf
#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

//swiftlint:disable file_length
public class Style {

    public static let defaultURI = StyleURI.streets

    public private(set) weak var styleManager: StyleManager!

    internal init(with styleManager: StyleManager) {
        self.styleManager = styleManager

        var uri: StyleURI?

        if let styleURL = URL(string: styleManager.getStyleURI()) {
            uri = StyleURI(rawValue: styleURL)
        }

        self.uri = uri ?? Self.defaultURI
    }

    // MARK: Layers

    /**
     Adds a `layer` to the map
     - Parameter layer: The layer to apply on the map
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `LayerError` in the `Result` failure case.
     */
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

     - Throws: `LayerError` on failure, or `NSError` with a _domain of "com.mapbox.bindgen"
     */
    public func _moveLayer(withId layerId: String, to position: LayerPosition) throws {
        let properties = try layerProperties(for: layerId)
        try removeLayer(withId: layerId)
        try addLayer(with: properties, layerPosition: position)
    }

    /**
     Gets a `layer` from the map
     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: Error
     */
    public func layer<T: Layer>(withId layerID: String, type: T.Type = T.self) throws -> T {
        // swiftlint:disable force_cast
        return try _layer(withId: layerID, type: type) as! T
        // swiftlint:enable force_cast
    }

    /**
     Gets a `layer` from the map.

     This function is useful if you do not know the concrete type of the layer
     you are fetching, or don't need to know for your situation.

     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: Error
     */
    public func _layer(withId layerID: String, type: Layer.Type) throws -> Layer {
        // Get the layer properties from the map
        let properties = try layerProperties(for: layerID)
        return try type.init(jsonObject: properties)
    }

    /// Updates a layer that exists in the style already
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    public func updateLayer<T: Layer>(id: String, type: T.Type, update: (inout T) throws -> Void) throws {
        var layer: T = try self.layer(withId: id, type: T.self)

        // Call closure to update the retrieved layer
        try update(&layer)

        let value = try layer.jsonObject()

        // Apply the changes to the layer properties to the style
        try setLayerProperties(for: id, properties: value)
    }

    // MARK: Layer properties

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

    // MARK: Sources

    /**
     Adds a source to the map
     - Parameter source: The source to add to the map.
     - Parameter identifier: A unique source identifier.
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `SourceError` in the `Result` failure case.
     */
    public func addSource(_ source: Source, id: String) throws {
        let sourceDictionary = try source.jsonObject()
        try addSource(withId: id, properties: sourceDictionary)
    }

    /**
     Retrieves a source from the map
     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type` is returned
                as part of the `Result`s success case if the operation is successful.
                Else, returns a `SourceError` as part of the `Result` failure case.
     */
    public func source<T: Source>(withId id: String, type: T.Type = T.self) throws -> T {
        // swiftlint:disable force_cast
        return try _source(withId: id, type: type) as! T
        // swiftlint:enable force_cast
    }

    /**
     Retrieves a source from the map

     This function is useful if you do not know the concrete type of the source
     you are fetching, or don't need to know for your situation.

     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type` is returned
                as part of the `Result`s success case if the operation is successful.
                Else, returns a `SourceError` as part of the `Result` failure case.
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

    /**
     Updates the `data` property of a given `GeoJSONSource` with a new value
     conforming to the `GeoJSONObject` protocol.

     - Parameter sourceIdentifier: The identifier representing the GeoJSON source.
     - Parameter geoJSON: The new GeoJSON to be associated with the source data.
     - Returns: If operation successful, returns a `true` as part of the `Result` success case.
                Else, returns an `Error` in the `Result` failure case.
     - Note: This method is only effective with sources of `GeoJSONSource` type,
             and should not be used to update other source types.
     */
    public func updateGeoJSONSource<T: GeoJSONObject>(withId sourceId: String, geoJSON: T) throws {
        let geoJSONDictionary = try GeoJSONManager.dictionaryFrom(geoJSON)
        try setSourceProperty(for: sourceId, property: "data", value: geoJSONDictionary as Any)
    }

    // MARK: Light

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> Any {
        return _lightProperty(property).value
    }

    // MARK: Terrain

    /// Sets a terrain on the style
    ///
    /// - Parameter terrain: The `Terrain` that should be rendered
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setTerrain(_ terrain: Terrain) throws {
        let terrainData = try JSONEncoder().encode(terrain)
        guard let terrainDictionary = try JSONSerialization.jsonObject(with: terrainData) as? [String: Any] else {
            throw StyleEncodingError.invalidJSONObject
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
}

// MARK: - StyleManagerProtocol

// See `StyleManagerProtocol` for documentation for the following APIs
// swiftlint:disable force_cast
extension Style: StyleManagerProtocol {
    public var isLoaded: Bool {
        return styleManager.isStyleLoaded()
    }

    public var uri: StyleURI {
        get {
            let uriString = styleManager.getStyleURI()
            guard let url = URL(string: uriString),
                  let styleURI = StyleURI(rawValue: url) else {
                fatalError()
            }
            return styleURI
        }
        set {
            styleManager.setStyleURIForUri(newValue.rawValue.absoluteString)
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

    // MARK: Layers

    public func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        let expected = styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition)
        if expected.isError() {
            throw LayerError.addLayerFailed(expected.error as! String)
        }
    }

    public func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        let expected = styleManager.addStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition)
        if expected.isError() {
            throw LayerError.addLayerFailed(expected.error as! String)
        }
    }

    public func removeLayer(withId id: String) throws {
        let expected = styleManager.removeStyleLayer(forLayerId: id)
        if expected.isError() {
            throw LayerError.removeLayerFailed(expected.error as! String)
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

    // MARK: Layer Properties

    public func _layerProperty(for layerId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleLayerProperty(forLayerId: layerId, property: property)
    }

    public func setLayerProperty(for layerId: String, property: String, value: Any) throws {
        let expected = styleManager.setStyleLayerPropertyForLayerId(layerId, property: property, value: value)
        if expected.isError() {
            throw LayerError.setLayerPropertyFailed(expected.error as! String)
        }
    }

    public static func _layerPropertyDefaultValue(for layerType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleLayerPropertyDefaultValue(forLayerType: layerType, property: property)
    }

    public func layerProperties(for layerId: String) throws -> [String: Any] {
        let expected = styleManager.getStyleLayerProperties(forLayerId: layerId)
        if expected.isError() {
            throw LayerError.getStyleLayerFailed(expected.error as! String)
        }

        guard let result = expected.value as? [String: Any] else {
            throw LayerError.getStyleLayerFailed("Value mismatch")
        }

        return result
    }

    public func setLayerProperties(for layerId: String, properties: [String: Any]) throws {
        let expected = styleManager.setStyleLayerPropertiesForLayerId(layerId, properties: properties)
        if expected.isError() {
            throw LayerError.setLayerPropertyFailed(expected.error as! String)
        }
    }

    // MARK: Sources

    public func addSource(withId sourceId: String, properties: [String: Any]) throws {
        let expected = styleManager.addStyleSource(forSourceId: sourceId, properties: properties)
        if expected.isError() {
            throw SourceError.addSourceFailed(expected.error as! String)
        }
    }

    public func removeSource(withId sourceId: String) throws {
        let expected = styleManager.removeStyleSource(forSourceId: sourceId)
        if expected.isError() {
            throw SourceError.removeSourceFailed(expected.error as! String)
        }
    }

    public func sourceExists(withId sourceId: String) -> Bool {
        return styleManager.styleSourceExists(forSourceId: sourceId)
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

    // MARK: Source properties

    public func _sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleSourceProperty(forSourceId: sourceId, property: property)
    }

    public func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        let expected = styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        if expected.isError() {
            throw SourceError.setSourceProperty(expected.error as! String)
        }
    }

    public func sourceProperties(for sourceId: String) throws -> [String: Any] {
        let expected = styleManager.getStyleSourceProperties(forSourceId: sourceId)
        if expected.isError() {
            throw SourceError.getSourceFailed(expected.error as! String)
        }

        guard let result = expected.value as? [String: Any] else {
            throw SourceError.getSourceFailed("Value mismatch")
        }
        return result
    }

    public func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        let expected = styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties)
        if expected.isError() {
            throw SourceError.setSourceProperty(expected.error as! String)
        }
    }

    public static func _sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    // MARK: Clustering

    public func geoJSONSourceClusterExpansionZoom(for sourceId: String, cluster: UInt32) throws -> Float {
        let expected = styleManager.getStyleGeoJSONSourceClusterExpansionZoom(forSourceId: sourceId, cluster: cluster)

        if expected.isError() {
            throw SourceError.getSourceClusterDetailsFailed(expected.error as! String)
        }

        guard let result = expected.value as? NSNumber else {
            throw SourceError.getSourceClusterDetailsFailed("Value mismatch")
        }
        return result.floatValue
    }

    public func geoJSONSourceClusterChildren(for sourceId: String, cluster: UInt32) throws -> [Feature] {
        let expected = styleManager.getStyleGeoJSONSourceClusterChildren(forSourceId: sourceId, cluster: cluster)

        if expected.isError() {
            throw SourceError.getSourceClusterDetailsFailed(expected.error as! String)
        }

        let features = expected.value as! [MBXFeature]

        return features.compactMap { Feature($0) }
    }

    public func geoJSONSourceClusterLeaves(for sourceId: String, cluster: UInt32, limit: UInt32, offset: UInt32) throws -> [Feature] {
        let expected = styleManager.getStyleGeoJSONSourceClusterLeaves(forSourceId: sourceId, cluster: cluster, limit: limit, offset: offset)

        if expected.isError() {
            throw SourceError.getSourceClusterDetailsFailed(expected.error as! String)
        }

        let features = expected.value as! [MBXFeature]

        return features.compactMap { Feature($0) }
    }

    // MARK: Image source

    public func updateImageSource(withId sourceId: String, image: UIImage) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw ImageError.convertingImageFailed("Failed to convert UIImage to MBMImage")
        }

        let expected = styleManager.updateStyleImageSourceImage(forSourceId: sourceId, image: mbmImage)

        if expected.isError() {
            throw ImageError.imageSourceImageUpdateFailed(expected.error as! String)
        }
    }

    // MARK: Style images

    public func addImage(_ image: UIImage, id: String, sdf: Bool = false, stretchX: [ImageStretches] = [], stretchY: [ImageStretches] = [], content: ImageContent? = nil) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw ImageError.convertingImageFailed("Failed to convert UIImage to MBMImage")
        }

        let expected = styleManager.addStyleImage(forImageId: id,
                                                  scale: Float(image.scale),
                                                  image: mbmImage,
                                                  sdf: sdf,
                                                  stretchX: stretchX,
                                                  stretchY: stretchY,
                                                  content: content)

        if expected.isError() {
            throw ImageError.addStyleImageFailed(expected.error as! String)
        }
    }

    public func removeImage(withId id: String) throws {
        let expected = styleManager.removeStyleImage(forImageId: id)

        if expected.isError() {
            throw ImageError.removeImageFailed(expected.error as! String)
        }
    }

    public func image(withId id: String) -> UIImage? {
        guard let mbmImage = styleManager.getStyleImage(forImageId: id) else {
            return nil
        }

        return UIImage(mbxImage: mbmImage)
    }

    // MARK: Style

    public func setLight(properties: [String: Any]) throws {
        let expected = styleManager.setStyleLightForProperties(properties)
        if expected.isError() {
            throw LightError.addLightFailed(expected.error as! String)
        }
    }

    public func _lightProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleLightProperty(forProperty: property)
    }

    public func setLightProperty(_ property: String, value: Any) throws {
        let expected = styleManager.setStyleLightPropertyForProperty(property, value: value)

        if expected.isError() {
            throw LightError.addLightFailed(expected.error as! String)
        }
    }

    // MARK: Terrain

    public func setTerrain(properties: [String: Any]) throws {
        let expected = styleManager.setStyleTerrainForProperties(properties)

        if expected.isError() {
            throw TerrainError.addTerrainFailed(expected.error as! String)
        }
    }

    public func _terrainProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleTerrainProperty(forProperty: property)
    }

    public func setTerrainProperty(_ property: String, value: Any) throws {
        let expected = styleManager.setStyleTerrainPropertyForProperty(property, value: value)

        if expected.isError() {
            // Temp error
            throw TerrainError.setTerrainProperty(expected.error as! String)
        }
    }

    // MARK: Custom geometry

    public func addCustomGeometrySource(withId sourceId: String, options: CustomGeometrySourceOptions) throws {
        let expected = styleManager.addStyleCustomGeometrySource(forSourceId: sourceId, options: options)

        if expected.isError() {
            throw TemporaryError.failure(expected.error as! String)
        }
    }

    // TODO: Fix initialization of MBXFeature.
    public func _setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Feature]) throws {
        let mbxFeatures = features.compactMap { MBXFeature($0) }
        let expected = styleManager.setStyleCustomGeometrySourceTileDataForSourceId(sourceId, tileId: tileId, featureCollection: mbxFeatures)

        if expected.isError() {
            throw TemporaryError.failure(expected.error as! String)
        }
    }

    public func invalidateCustomGeometrySourceTile(forSourceId sourceId: String, tileId: CanonicalTileID) throws {
        let expected = styleManager.invalidateStyleCustomGeometrySourceTile(forSourceId: sourceId, tileId: tileId)

        if expected.isError() {
            throw TemporaryError.failure(expected.error as! String)
        }
    }

    public func invalidateCustomGeometrySourceRegion(forSourceId sourceId: String, bounds: CoordinateBounds) throws {
        let expected = styleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId: sourceId, bounds: bounds)

        if expected.isError() {
            throw TemporaryError.failure(expected.error as! String)
        }
    }
}
// swiftlint:enable force_cast

// MARK: - StyleTransition

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
