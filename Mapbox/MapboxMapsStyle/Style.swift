import Turf
#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

// MARK: - Style error types

/// All source related errors
public enum SourceError: Error {
    /// The source could not be encoded to JSON
    case sourceEncodingFailed(Error)

    /// The source could not be decoded from JSON
    case sourceDecodingFailed(Error)

    /// The source could not be added to the map
    case addSourceFailed(String?)

    /// The source could not be retrieved from the map
    case getSourceFailed(String?)

    /// The source property could not be set.
    case setSourceProperty(String?)

    /// The source could not be removed from the map
    case removeSourceFailed(String?)
}

/// Error enum for all layer-related errors
public enum LayerError: Error {
    /// The layer provided to the map in `addLayer()` could not be encoded
    case layerEncodingFailed(Error)

    /// The layer retrieved from the map could not be decoded.
    case layerDecodingFailed(Error)

    /// Addding the style layer to the map failed
    case addStyleLayerFailed(String?)

    /// The layer properties for a layer are nil
    case getStyleLayerFailed(String?)

    /// Remove the style layer from the map failed
    case removeStyleLayerFailed(String?)

    /// The retrieved layer is nil
    case retrievedLayerIsNil

    /// Updating the layer failed with error
    case updateStyleLayerFailed(Error)
}

/// Error enum for all image-related errors
public enum ImageError: Error {
    /// Converting the input image to internal `Image` format failed.
    case convertingImageFailed(String?)

    /// Adding the image to the style's sprite failed.
    case addStyleImageFailed(String?)

    /// The style image does not exist in the sprite
    case getStyleImageFailed(String?)
}

/// Error enum for all terrain-related errors
public enum TerrainError: Error {
    /// Decoding terrain failed
    case decodingTerrainFailed(Error)
    /// Adding terrain failed
    case addTerrainFailed(String?)
}

/// Enum for all light-related errors
public enum LightError: Error {
    /// Adding a new light object to style failed
    case addLightFailed(String?)

    /// Retrieving a light object from style failed
    case getLightFailed(Error)
}

public class Style {
    public private(set) weak var styleManager: StyleManager!

    internal var styleUrl: StyleURL = .streets

    private var layerCache: [String: Layer] = [:]

    public init(with styleManager: StyleManager) {
        self.styleManager = styleManager
    }

    // Could we use a mutating function here?
    /**
     URL of the style currently displayed in the receiver.

     The URL may be a full HTTP or HTTPS URL ,a Mapbox style
     URL (mapbox://styles/{user}/{style}), or a URL for a style
     JSON file.

     If you set this property to `nil`, the
     receiver will use the default style and this property will
     automatically be set to that style’s URL.
     */
    public var styleURL: StyleURL = .streets {
        didSet {
            let uriString = styleURL.url.absoluteString
            try! self.styleManager.setStyleURIForUri(uriString)
        }
    }

    // MARK: Layers

    /**
     Adds a `layer` to the map
     - Parameter layer: The layer to apply on the map
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `LayerError` in the `Result` failure case.
     */
    @discardableResult
    public func addLayer<T: Layer>(layer: T, layerPosition: LayerPosition? = nil) -> Result<Bool, LayerError> {

        // Attempt to encode the provided layer into JSON and apply it to the map
        do {
            let layerData = try JSONEncoder().encode(layer)
            //swiftlint:disable force_cast
            let layerJSON = try JSONSerialization.jsonObject(with: layerData) as! [String: AnyObject]
            let expected = try! self.styleManager.addStyleLayer(forProperties: layerJSON, layerPosition: layerPosition)

            if expected.isError() {
                return .failure(.addStyleLayerFailed(expected.error as? String))
            } else {
                self.layerCache[layer.id] = layer
                return .success(true)
            }
        } catch {
            // Return failure if we run into an issue
            return .failure(.layerEncodingFailed(error))
        }
    }

    /**
     Gets a `layer` from the map
     - Parameter layerID: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched
     - Returns: The fully formed `layer` object of type equal to `type` is returned as
                part of the `Result`s success case if the operation is successful.
                Else, returns a `LayerError` as part of the `Result` failure case.

     */
    public func getLayer<T: Layer>(with layerID: String, type: T.Type) -> Result<T, LayerError> {

        // Try to get layer from cache if possible
        if let cachedLayer = layerCache[layerID] as? T {
            return .success(cachedLayer)
        }

        // If layer not in cache, get the layer properties from the map directly
        var layerProps: MBXExpected<AnyObject, AnyObject>?
        do {
            layerProps = try self.styleManager.getStyleLayerProperties(forLayerId: layerID)
        } catch {
            return .failure(.getStyleLayerFailed(nil))
        }

        // If layerProps represents an error, return early
        guard let validLayerProps = layerProps, validLayerProps.isValue(),
            let validValue = validLayerProps.value else {
            return .failure(.getStyleLayerFailed(layerProps?.error as? String))
        }

        // Decode the layer properties into a layer object
        do {
            let layerData = try JSONSerialization.data(withJSONObject: validValue)
            let layer = try JSONDecoder().decode(type, from: layerData)
            return .success(layer)
        } catch {
            return .failure(.layerDecodingFailed(error))
        }
    }

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
     - Parameter scale: The scale factor for the image.
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
                              scale: CGFloat,
                              imageContent: ImageContent? = nil) -> Result<Bool, ImageError> {

        /**
         TODO: Define interfaces for stretchX/Y/imageContent,
         as these are core SDK types.
         */

        guard let mbxImage = Image(uiImage: image) else {
            return .failure(.convertingImageFailed(nil))
        }

        let expected = try! styleManager.addStyleImage(forImageId: identifier,
                                              scale: 3.0,
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
        return try! styleManager.getStyleImage(forImageId: identifier)
    }

    /**
     Remove a style layer from the map with specific id.

     - Returns: A boolean associated with a `Result` type if the operation is successful.
                Otherwise, this will return a `LayerError` as part of the `Result` failure case.
     */
    public func removeStyleLayer(forLayerId: String) -> Result<Bool, LayerError> {
        let expected = try! styleManager.removeStyleLayer(forLayerId: forLayerId)

        return expected.isError() ? .failure(.removeStyleLayerFailed(expected.error as? String))
                                  : .success(true)
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
    public func addSource<T: Source>(source: T, identifier: String) -> Result<Bool, SourceError> {

        // Attempt to encode the provided source into JSON and apply it to the map
        do {
            let sourceData = try JSONEncoder().encode(source)
            let sourceDictionary = try JSONSerialization.jsonObject(with: sourceData)
            let expected = try! self.styleManager.addStyleSource(forSourceId: identifier, properties: sourceDictionary)

            return expected.isValue() ? .success(true)
                                      : .failure(.addSourceFailed(expected.error as? String))
        } catch {
            return .failure(.sourceEncodingFailed(error))
        }
    }

    /**
     Retrieves a source from the map
     - Parameter identifier: The id of the source to retrieve
     - Parameter type: The type of the source
     - Returns: The fully formed `source` object of type equal to `type` is returned
                as part of the `Result`s success case if the operation is successful.
                Else, returns a `SourceError` as part of the `Result` failure case.
     */
    public func getSource<T: Source>(identifier: String, type: T.Type) -> Result<T, SourceError> {

        // Get the source properties for a given identifier
        let sourceProps = try! self.styleManager.getStyleSourceProperties(forSourceId: identifier)

        // If sourceProps represents an error, return early
        guard sourceProps.isValue(),
            let validValue = sourceProps.value else {
                return .failure(.getSourceFailed(sourceProps.error as? String))
        }

        // Decode the source properties into a source object
        do {
            let sourceData = try JSONSerialization.data(withJSONObject: validValue)
                let source = try JSONDecoder().decode(type, from: sourceData)
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
        let expectation = try! styleManager.setStyleSourcePropertyForSourceId(id, property: property, value: value)

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

        return self.updateSourceProperty(id: sourceIdentifier,
                                         property: "data",
                                         value: geoJSONDictionary)
    }

    /// Sets a terrain on the style
    /// - Parameter terrain: The `Terrain` that should be rendered
    /// - Returns: Result type with `.success` if terrain is successfully applied. `TerrainError` otherwise.
    @discardableResult
    public func setTerrain(_ terrain: Terrain) -> Result<Bool, TerrainError> {
        do {
            let terrainData = try JSONEncoder().encode(terrain)
            let terrainDictionary = try JSONSerialization.jsonObject(with: terrainData)
            let expectation = try styleManager.setStyleTerrainForProperties(terrainDictionary)

            return expectation.isValue() ? .success(true)
                                         : .failure(.addTerrainFailed(expectation.error as? String))
        } catch {
            return .failure(.decodingTerrainFailed(error))
        }
    }

    /**
     Remove a source with a specified identifier from the map.
     - Parameter sourceID: The unique identifer representing the source to be removed.
     - Returns: If operation successful, returns a `true` as part of the `Result`
                success case. Else, returns a `SourceError` in the `Result` failure case.
     */
    public func removeSource(for sourceID: String) -> Result<Bool, SourceError> {
        let expected = try! styleManager.removeStyleSource(forSourceId: sourceID)

        return expected.isError() ? .failure(.removeSourceFailed(expected.error as? String))
                                  : .success(true)
    }

    /// Add a light object to the map's style
    /// - Parameter light: The `Light` object to be applied to the style.
    /// - Returns: IF operation successful, returns a `true` as part of the `Result`.  Else returns a `LightError`.
    public func addLight(_ light: Light) -> Result<Bool, LightError> {
        do {
            let lightData = try JSONEncoder().encode(light)
            let lightDictionary = try JSONSerialization.jsonObject(with: lightData)
            let expectation = try styleManager.setStyleTerrainForProperties(lightDictionary)

            return expectation.isValue() ? .success(true)
                                         : .failure(.addLightFailed(expectation.error as? String))
        } catch {
            return .failure(.addLightFailed(nil))
        }
    }

    /// Updates a layer that exists in the style already
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    /// - Returns: Result type with  `.success` if update is successful, `LayerError` otherwise
    @discardableResult
    func updateLayer<T: Layer>(id: String, type: T.Type, update: (inout T) -> Void) -> Result<Bool, LayerError> {

        let result = self.getLayer(with: id, type: T.self)
        var layer: T?

        // Fetch the layer from the style
        switch result {
        case .success(let retrievedLayer):
            // Successfully retrieved the layer
            layer = retrievedLayer
        case .failure(_):

            // Could not retrieve the layer
            return .failure(.getStyleLayerFailed(nil))
        }

        guard var validLayer = layer else {
            return .failure(.retrievedLayerIsNil)
        }

        // Call closure to update the retrieved layer
        update(&validLayer)

        do {
            let data = try JSONEncoder().encode(validLayer)
            let value = try JSONSerialization.jsonObject(with: data, options: [])

            // Apply the changes to the layer properties to the style
            try self.styleManager.setStyleLayerPropertiesForLayerId(id, properties: value)
            return .success(true)
        } catch {
            return .failure(.updateStyleLayerFailed(error))
        }
    }
}

/**
 The transition property for a layer.
 A transition property controls timing for the interpolation between a
 transitionable style property's previous value and new value.
 */
public struct StyleTransition: Codable {

    /// Time allotted for transitions to complete.
    public var duration: TimeInterval = 0

    /// Length of time before a transition begins.
    public var delay: TimeInterval = 0

    public init(duration: TimeInterval, delay: TimeInterval) {
        self.duration = duration
        self.delay = delay
    }
}
