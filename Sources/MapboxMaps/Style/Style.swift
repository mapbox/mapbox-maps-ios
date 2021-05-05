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
    public func _moveLayer(with layerId: String, to position: LayerPosition) throws {
        let properties = try layerProperties(for: layerId)
        try removeLayer(withId: layerId)
        try addLayer(with: properties, layerPosition: position)
    }

    /**
     Gets a `layer` from the map
     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched
     - Returns: The fully formed `layer` object of type equal to `type` is returned as
                part of the `Result`s success case if the operation is successful.
                Else, returns a `LayerError` as part of the `Result` failure case.
     */
    public func getLayer<T: Layer>(with layerID: String, type: T.Type = T.self) -> Result<T, LayerError> {
        let layerResult = _layer(with: layerID, type: type)
        switch layerResult {
        case .success(let layer):
            // swiftlint:disable force_cast
            return .success(layer as! T)
            // swiftlint:enable force_cast
        case .failure(let error):
            return .failure(error)
        }
    }

    /**
     Gets a `layer` from the map.

     This function is useful if you do not know the concrete type of the layer
     you are fetching, or don't need to know for your situation.

     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched
     - Returns: The fully formed `layer` object of type equal to `type` is returned as
                part of the `Result`s success case if the operation is successful.
                Else, returns a `LayerError` as part of the `Result` failure case.
     */
    public func _layer(with layerID: String, type: Layer.Type) -> Result<Layer, LayerError> {

        // Get the layer properties from the map
        do {
            let layerProps = try layerProperties(for: layerID)
            let layer = try type.init(jsonObject: layerProps)
            return .success(layer)
        } catch {
            return .failure(.layerDecodingFailed(error))
        }
    }

    /// Updates a layer that exists in the style already
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    /// - Returns: Result type with  `.success` if update is successful, `LayerError` otherwise
    @discardableResult
    public func updateLayer<T: Layer>(id: String, type: T.Type, update: (inout T) -> Void) -> Result<Bool, LayerError> {

        let result: Result<T, LayerError> = getLayer(with: id, type: T.self)
        var layer: T

        // Fetch the layer from the style
        switch result {
        case .success(let retrievedLayer):
            // Successfully retrieved the layer
            layer = retrievedLayer
        case .failure:

            // Could not retrieve the layer
            return .failure(.getStyleLayerFailed("Could not retrieve the layer"))
        }

        // Call closure to update the retrieved layer
        update(&layer)

        do {
            let value = try layer.jsonObject()

            // Apply the changes to the layer properties to the style
            try setLayerProperties(for: id, properties: value)
            return .success(true)
        } catch {
            return .failure(.updateStyleLayerFailed(error))
        }
    }

    // MARK: Style images

    /**
     Add a given `UIImage` to the map style's sprite, or updates
     the given image in the sprite if it already exists.

     You must call this method after the map's style has finished loading in order
     to set any image or pattern properties on a style layer.

     - Parameter image: The image to be added to the map style's sprite.
     - Parameter identifier: The name of the image the map style's sprite
                             will use for identification.
     - Parameter sdf: Whether or not the image is treated as a signed distance field.
                      Defaults to `false`.
     - Parameter stretchX: The array of horizontal image stretch areas.
                           Defaults to an empty array.
     - Parameter stretchY: The array of vertical image stretch areas.
                           Defaults to an empty array.
     - Parameter imageContent: The `ImageContent` which describes where text
                               can be fit into an image. By default, this is `nil`.
     - Returns: A boolean associated with a `Result` type if the operation is successful.
                Otherwise, this will return a `StyleError` as part of the `Result` failure case.
     */
    @discardableResult
    public func setStyleImage(image: UIImage,
                              with identifier: String,
                              sdf: Bool = false,
                              stretchX: [ImageStretches] = [],
                              stretchY: [ImageStretches] = [],
                              imageContent: ImageContent? = nil) -> Result<Bool, ImageError> {

        /**
         TODO: Define interfaces for stretchX/Y/imageContent,
         as these are core SDK types.
         */

        guard let mbxImage = Image(uiImage: image) else {
            return .failure(.convertingImageFailed(nil))
        }

        let expected = styleManager.addStyleImage(forImageId: identifier,
                                                  scale: Float(image.scale),
                                                  image: mbxImage,
                                                  sdf: sdf,
                                                  stretchX: stretchX,
                                                  stretchY: stretchY,
                                                  content: imageContent)

        return expected.isError() ? .failure(.addStyleImageFailed(expected.error as? String))
                                  : .success(true)
    }

    public func getStyleImage(with identifier: String) -> Image? {
        // TODO: Send back UIImage, not MBX Image
        return styleManager.getStyleImage(forImageId: identifier)
    }

    // MARK: Sources

    /**
     Adds a source to the map
     - Parameter source: The source to add to the map.
     - Parameter identifier: A unique source identifier.
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `SourceError` in the `Result` failure case.
     */
    @discardableResult
    public func addSource(source: Source, identifier: String) -> Result<Bool, SourceError> {

        // Attempt to encode the provided source into JSON and apply it to the map
        do {
            let sourceDictionary = try source.jsonObject()
            let expected = styleManager.addStyleSource(forSourceId: identifier, properties: sourceDictionary)

            return expected.isValue() ? .success(true)
                                      : .failure(.addSourceFailed(expected.error as? String))
        } catch {
            return .failure(.sourceEncodingFailed(error))
        }
    }

    /**
     Remove a source with a specified identifier from the map.
     - Parameter sourceID: The unique identifer representing the source to be removed.
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `SourceError` in the `Result` failure case.
     */
    public func removeSource(for sourceID: String) -> Result<Bool, SourceError> {
        let expected = styleManager.removeStyleSource(forSourceId: sourceID)

        return expected.isError() ? .failure(.removeSourceFailed(expected.error as? String))
                                  : .success(true)
    }

    /**
     Retrieves a source from the map
     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type` is returned
                as part of the `Result`s success case if the operation is successful.
                Else, returns a `SourceError` as part of the `Result` failure case.
     */
    public func getSource<T: Source>(identifier: String, type: T.Type = T.self) -> Result<T, SourceError> {
        let sourceResult = _source(identifier: identifier, type: type)
        switch sourceResult {
        case .success(let source):
            // swiftlint:disable force_cast
            return .success(source as! T)
            // swiftlint:enable force_cast
        case .failure(let error):
            return .failure(error)
        }
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
    public func _source(identifier: String, type: Source.Type) -> Result<Source, SourceError> {
        // Get the source properties for a given identifier
        let sourceProps = styleManager.getStyleSourceProperties(forSourceId: identifier)

        // If sourceProps represents an error, return early
        guard sourceProps.isValue(),
              let validValue = sourceProps.value as? [String: AnyObject] else {
            return .failure(.getSourceFailed(sourceProps.error as? String))
        }

        // Decode the source properties into a source object
        do {
            let source = try type.init(jsonObject: validValue)
            return .success(source)
        } catch {
            return .failure(.sourceDecodingFailed(error))
        }
    }

    /**
     Set a source property for a given source to an updated value.

     - Parameter id: The identifier representing the source.
     - Parameter property: The name of the source property to change.
     - Parameter value: The new value to for the `property`.
     - Returns: If operation successful, returns a `true` as part of the `Result` success case.
                Else, returns a `SourceError` in the `Result` failure case.
     */
    @discardableResult
    public func updateSourceProperty(id: String, property: String, value: [String: Any]) -> Result<Bool, SourceError> {
        let expectation = styleManager.setStyleSourcePropertyForSourceId(id, property: property, value: value)

        return expectation.isValue() ? .success(true)
                                     : .failure(.setSourceProperty(expectation.error as? String))
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
    public func updateGeoJSON<T: GeoJSONObject>(for sourceIdentifier: String, with geoJSON: T) -> Result<Bool, SourceError> {

        guard let geoJSONDictionary = try? GeoJSONManager.dictionaryFrom(geoJSON) else {
            return .failure(.setSourceProperty("Could not parse updated GeoJSON"))
        }

        return updateSourceProperty(id: sourceIdentifier,
                                    property: "data",
                                    value: geoJSONDictionary)
    }

    // MARK: Terrain

    /// Sets a terrain on the style
    /// - Parameter terrain: The `Terrain` that should be rendered
    /// - Returns: Result type with `.success` if terrain is successfully applied. `TerrainError` otherwise.
    @discardableResult
    public func setTerrain(_ terrain: Terrain) -> Result<Bool, TerrainError> {
        do {
            let terrainData = try JSONEncoder().encode(terrain)
            let terrainDictionary = try JSONSerialization.jsonObject(with: terrainData)
            let expectation = styleManager.setStyleTerrainForProperties(terrainDictionary)

            return expectation.isValue() ? .success(true)
                                         : .failure(.addTerrainFailed(expectation.error as? String))
        } catch {
            return .failure(.decodingTerrainFailed(error))
        }
    }

    /// Add a light object to the map's style
    /// - Parameter light: The `Light` object to be applied to the style.
    /// - Returns: IF operation successful, returns a `true` as part of the `Result`.  Else returns a `LightError`.
    public func addLight(_ light: Light) -> Result<Bool, LightError> {
        do {
            let lightData = try JSONEncoder().encode(light)
            let lightDictionary = try JSONSerialization.jsonObject(with: lightData)
            let expectation = styleManager.setStyleTerrainForProperties(lightDictionary)

            return expectation.isValue() ? .success(true)
                                         : .failure(.addLightFailed(expectation.error as? String))
        } catch {
            return .failure(.addLightFailed(nil))
        }
    }
}

// MARK: - StyleManagerProtocol

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

    public var layerIdentifiers: [LayerInfo] {
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
