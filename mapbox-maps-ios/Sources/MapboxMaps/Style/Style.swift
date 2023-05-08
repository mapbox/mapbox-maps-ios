// swiftlint:disable file_length
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private
import UIKit

internal protocol StyleProtocol: AnyObject {
    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws
    func removeLayer(withId id: String) throws
    func layerExists(withId id: String) -> Bool
    func layerProperties(for layerId: String) throws -> [String: Any]
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws
    func setLayerProperty(for layerId: String, property: String, value: Any) throws

    func addSource(_ source: Source, id: String, dataId: String?) throws
    func removeSource(withId id: String) throws
    func sourceExists(withId id: String) -> Bool
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String?) throws

    //swiftlint:disable:next function_parameter_count
    func addImage(_ image: UIImage,
                  id: String,
                  sdf: Bool,
                  stretchX: [ImageStretches],
                  stretchY: [ImageStretches],
                  content: ImageContent?) throws
    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) throws
    func removeImage(withId id: String) throws
    func imageExists(withId id: String) -> Bool
}

internal extension StyleProtocol {
    func addImage(_ image: UIImage, id: String, sdf: Bool = false, contentInsets: UIEdgeInsets = .zero) throws {
        try addImage(image, id: id, sdf: sdf, contentInsets: contentInsets)
    }
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String? = nil) throws {
        try updateGeoJSONSource(withId: id, geoJSON: geoJSON, dataId: dataId)
    }
    func addSource(_ source: Source, id: String, dataId: String? = nil)  throws {
        try addSource(source, id: id, dataId: dataId)
    }
}

// swiftlint:disable type_body_length

/// Style provides access to the APIs used to dynamically modify the map's style. Use it
/// to read and write layers, sources, and images. Obtain the Style instance for a MapView
/// via MapView.mapboxMap.style.
///
/// - Important: Style should only be used from the main thread.
public final class Style: StyleProtocol {

    private let sourceManager: StyleSourceManagerProtocol
    private let _styleManager: StyleManagerProtocol
    public weak var styleManager: StyleManager! {
        _styleManager.asStyleManager()
    }

    internal convenience init(with styleManager: StyleManagerProtocol) {
        self.init(with: styleManager, sourceManager: StyleSourceManager(styleManager: styleManager))
    }

    internal init(with styleManager: StyleManagerProtocol, sourceManager: StyleSourceManagerProtocol) {
        self._styleManager = styleManager
        self.sourceManager = sourceManager

        if let uri = StyleURI(rawValue: styleManager.getStyleURI()) {
            self.uri = uri
        }
    }

    // MARK: - Layers

    /// Adds a `layer` to the map
    ///
    /// - Parameters:
    ///   - layer: The layer to apply on the map
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws: ``StyleError`` if there is a problem adding the given `layer` at the given `position`.
    public func addLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        // Attempt to encode the provided layer into a dictionary and apply it to the map.
        let layerProperties = try layer.allStyleProperties()
        try addLayer(with: layerProperties, layerPosition: layerPosition)
    }

    /// Adds a  persistent `layer` to the map.
    /// Persistent layers are valid across `style` changes.
    ///
    /// - Parameters:
    ///   - layer: The layer to apply on the map
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws: ``StyleError`` if there is a problem adding the persistent layer.
    public func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        // Attempt to encode the provided layer into a dictionary and apply it to the map.
        let layerProperties = try layer.allStyleProperties()
        try addPersistentLayer(with: layerProperties, layerPosition: layerPosition)
    }

    /**
     Moves a `layer` to a new layer position in the style.
     - Parameter layerId: The layer to move
     - Parameter position: Position to move the layer in the stack of layers on the map. Defaults to the top layer.

     - Throws: `StyleError` on failure, or `NSError` with a _domain of "com.mapbox.bindgen"
     */
    public func moveLayer(withId id: String, to position: LayerPosition) throws {
        try handleExpected {
            _styleManager.moveStyleLayer(forLayerId: id, layerPosition: position.corePosition)
        }
    }

    /**
     Gets a `layer` from the map
     - Parameter id: The id of the layer to be fetched
     - Parameter type: The type of the layer that will be fetched

     - Returns: The fully formed `layer` object of type equal to `type`
     - Throws: ``StyleError`` if there is a problem getting the layer data.
     - Throws: ``TypeConversionError`` is there is a problem decoding the layer data to the given `type`.
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

    /// Updates a `layer` that exists in the `style` already
    ///
    /// - Parameters:
    ///   - id: identifier of layer to update
    ///   - type: Type of the layer
    ///   - update: Closure that mutates a layer passed to it
    ///
    /// - Throws: ``TypeConversionError`` if there is a problem getting a layer data.
    /// - Throws: ``StyleError`` if there is a problem updating the layer.
    /// - Throws: An error when executing `update` block.
    public func updateLayer<T>(withId id: String,
                               type: T.Type,
                               update: (inout T) throws -> Void) throws where T: Layer {
        let oldLayerProperties = try layerProperties(for: id)
        var layer = try T(jsonObject: oldLayerProperties)

        // Call closure to update the retrieved layer
        try update(&layer)

        let reduceStrategy: (inout [String: Any], Dictionary<String, Any>.Element) -> Void = { result, element in
            let (key, value) = element
            switch value {
            case Optional<Any>.none where result.keys.contains(key):
                result[key] = Style.layerPropertyDefaultValue(for: layer.type, property: key).value
            // swiftlint:disable:next syntactic_sugar
            case Optional<Any>.some:
                result[key] = value
            default: break
            }
        }
        let layerProperties: [String: Any] = try layer
            .allStyleProperties(userInfo: [:], shouldEncodeNilValues: true)
            .reduce(into: oldLayerProperties, { result, element in
                if let dictionary = element.value as? [String: Any] {
                    result[element.key] = dictionary.reduce(
                        into: oldLayerProperties[element.key] as? [String: Any] ?? [:],
                        reduceStrategy
                    )
                } else {
                    reduceStrategy(&result, element)
                }
            })

        // Apply the changes to the layer properties to the style
        try setLayerProperties(for: id, properties: layerProperties)
    }

    // MARK: - Sources

    /**
     Adds a `source` to the map
     - Parameter source: The source to add to the map.
     - Parameter identifier: A unique source identifier.
     - Parameter dataId: An optional data ID to filter ``MapEvents.sourceDataLoaded`` to only the specified data source.
     /// Applies only to GeoJSONSources

     - Throws: ``StyleError`` if there is a problem adding the `source`.
     */
    public func addSource(_ source: Source, id: String, dataId: String? = nil) throws {
        try sourceManager.addSource(source, id: id, dataId: dataId)
    }

    /**
     Retrieves a `source` from the map
     - Parameter id: The id of the source to retrieve
     - Parameter type: The type of the source

     - Returns: The fully formed `source` object of type equal to `type`.
     - Throws: ``StyleError`` if there is a problem getting the source data.
     - Throws: ``TypeConversionError`` if there is a problem decoding the source data to the given `type`.
     */
    public func source<T>(withId id: String, type: T.Type) throws -> T where T: Source {
        try sourceManager.source(withId: id, type: type)
    }

    /**
     Retrieves a `source` from the map

     This function is useful if you do not know the concrete type of the source
     you are fetching, or don't need to know for your situation.

     - Parameter id: The id of the `source` to retrieve.
     - Returns: The fully formed `source` object.
     - Throws: ``StyleError`` if there is a problem getting the source data.
     - Throws: ``TypeConversionError`` if there is a problem decoding the source of given `id`.
     */
    public func source(withId id: String) throws -> Source {
        try sourceManager.source(withId: id)
    }

    /// Updates the `data` property of a given `GeoJSONSource` with a new value
    /// conforming to the `GeoJSONObject` protocol.
    ///
    /// - Parameters:
    ///   - id: The identifier representing the GeoJSON source.
    ///   - geoJSON: The new GeoJSON to be associated with the source data. i.e.
    ///   a feature or feature collection.
    ///   - dataId: An optional data ID to filter ``MapEvents.sourceDataLoaded`` to only the specified data source
    ///
    /// - Throws: ``StyleError`` if there is a problem when updating GeoJSON source.
    ///
    /// - Attention: This method is only effective with sources of `GeoJSONSource`
    /// type, and cannot be used to update other source types.
    public func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String? = nil) throws {
        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSON, dataId: dataId)
    }

    /// `true` if and only if the style JSON contents, the style specified sprite,
    /// and sources are all loaded, otherwise returns `false`.
    public var isLoaded: Bool {
        return _styleManager.isStyleLoaded()
    }

    /// Get or set the style URI
    ///
    /// Setting a new style is asynchronous. In order to get the result of this
    /// operation, listen to `MapEvents.styleDataLoaded`, `MapEvents.styleLoaded`.
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    public var uri: StyleURI? {
        get {
            let uriString = _styleManager.getStyleURI()

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
                _styleManager.setStyleURIForUri(uriString)
            }
        }
    }

    /// Get or set the style via a JSON serialization string
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    public var JSON: String {
        get {
            _styleManager.getStyleJSON()
        }
        set {
            _styleManager.setStyleJSONForJson(newValue)
        }
    }

    /// The map `style`'s default camera, if any, or a default camera otherwise.
    /// The map `style` default camera is defined as follows:
    ///
    /// - [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center)
    /// - [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-zoom)
    /// - [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing)
    /// - [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch)
    ///
    /// The `style` default camera is re-evaluated when a new `style` is loaded. Values default to 0.0 if they are not defined in the `style`.
    public var defaultCamera: CameraOptions {
        return CameraOptions(_styleManager.getStyleDefaultCamera())
    }

    /// Get or set the map `style`'s transition options.
    ///
    /// By default, the style parser will attempt to read the style default
    /// transition, if any, falling back to a 0.3 s transition otherwise.
    ///
    /// Overridden transitions are reset once a new style has been loaded.
    /// To customize the transition used when switching styles, set this
    /// property after `MapEvents.EventKind.styleDataLoaded` where
    /// `Event.type == "style"` and before
    /// `MapEvents.EventKind.styleDataLoaded` where `Event.type == "sprite"`
    /// and where `Event.type == "sources"`.
    /// - SeeAlso: ``MapboxMap/onNext(_:handler:)``
    public var transition: TransitionOptions {
        get {
            _styleManager.getStyleTransition()
        }
        set {
            _styleManager.setStyleTransitionFor(newValue)
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
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        try handleExpected {
            return _styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Adds a new persistent style layer given its JSON properties
    ///
    /// Persistent style layers remain valid across style reloads.
    ///
    /// - Parameters:
    ///   - properties: A JSON dictionary of style layer properties
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful
    public func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        try handleExpected {
            return _styleManager.addPersistentStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Returns `true` if the id passed in is associated to a persistent layer
    /// - Parameter id: The layer identifier to test
    public func isPersistentLayer(id: String) throws -> Bool {
        return try handleExpected {
            return _styleManager.isStyleLayerPersistent(forLayerId: id)
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
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addPersistentCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        try handleExpected {
            return _styleManager.addPersistentStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition?.corePosition)
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
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        try handleExpected {
            return _styleManager.addStyleCustomLayer(forLayerId: id, layerHost: layerHost, layerPosition: layerPosition?.corePosition)
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
        try handleExpected {
            return _styleManager.removeStyleLayer(forLayerId: id)
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
        return _styleManager.styleLayerExists(forLayerId: id)
    }

    /// The ordered list of the current style layers' identifiers and types
    public var allLayerIdentifiers: [LayerInfo] {
        return _styleManager.getStyleLayers().compactMap { info in
            if info.is3DPuckLayer { return nil }

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
        return _styleManager.getStyleLayerProperty(forLayerId: layerId, property: property)
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
        try handleExpected {
            return _styleManager.setStyleLayerPropertyForLayerId(layerId, property: property, value: value)
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
            return _styleManager.getStyleLayerProperties(forLayerId: layerId)
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
        try handleExpected {
            return _styleManager.setStyleLayerPropertiesForLayerId(layerId, properties: properties)
        }
    }

    // MARK: - Sources

    /// Adds a new style source.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#sources
    ///
    /// - Parameters:
    ///   - id: An identifier for the style source.
    ///   - properties: A JSON dictionary of style source properties.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addSource(withId id: String, properties: [String: Any]) throws {
        try sourceManager.addSource(withId: id, properties: properties)
    }

    /// Removes an existing style source.
    ///
    /// - Parameter id: Identifier of the style source to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func removeSource(withId id: String) throws {
        try sourceManager.removeSource(withId: id)
    }

    /// Checks whether a given style source exists.
    ///
    /// - Parameter id: Style source identifier.
    ///
    /// - Returns: `true` if the given source exists, `false` otherwise.
    public func sourceExists(withId id: String) -> Bool {
        return sourceManager.sourceExists(withId: id)
    }

    /// The ordered list of the current style sources' identifiers and types. Identifiers for custom vector
    /// sources will not be included
    public var allSourceIdentifiers: [SourceInfo] {
        return sourceManager.allSourceIdentifiers
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
        return sourceManager.sourceProperty(for: sourceId, property: property)
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
        try sourceManager.setSourceProperty(for: sourceId, property: property, value: value)
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
        return try sourceManager.sourceProperties(for: sourceId)
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
        try sourceManager.setSourceProperties(for: sourceId, properties: properties)
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
        return StyleSourceManager.sourcePropertyDefaultValue(for: sourceType, property: property)
    }

    // MARK: - Image source

    /// Updates the image of an image style source.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#sources-image
    ///
    /// - Parameters:
    ///   - id: Style source identifier.
    ///   - image: UIImage
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func updateImageSource(withId id: String, image: UIImage) throws {
        guard let mbmImage = Image(uiImage: image) else {
            throw TypeConversionError.unexpectedType
        }

        try handleExpected {
            return styleManager.updateStyleImageSourceImage(forSourceId: id, image: mbmImage)
        }
    }

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
    /// For more information on how `stretchX` and `stretchY` parameters affect image stretching
    /// see [this Mapbox GL-JS example](https://docs.mapbox.com/mapbox-gl-js/example/add-image-stretchable).
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

        try handleExpected {
            return _styleManager.addStyleImage(forImageId: id,
                                               scale: Float(image.scale),
                                               image: mbmImage,
                                               sdf: sdf,
                                               stretchX: stretchX,
                                               stretchY: stretchY,
                                               content: content)
        }
    }

    /// Adds an image to be used in the style.
    ///
    /// If the image has non-zero `UIImage.capInsets` it will be stretched accordingly,
    /// regardless of the value in `UIImage.resizingMode`.
    ///
    /// - Parameters:
    ///   - image: Image to add.
    ///   - id: ID of the image.
    ///   - sdf: Option to treat whether image is SDF(signed distance field) or not.
    ///         Setting this to `true` allows template images to be recolored. The
    ///         default value is `false`.
    ///   - contentInsets: The distances the edges of content are inset from the image rectangle.
    ///         If present, and if the icon uses icon-text-fit, the
    ///         symbol's text will be fit inside the content box.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addImage(_ image: UIImage, id: String, sdf: Bool = false, contentInsets: UIEdgeInsets = .zero) throws {
        let scale = Float(image.scale)
        let stretchXFirst = Float(image.capInsets.left) * scale
        let stretchXSecond = Float(image.size.width - image.capInsets.right) * scale
        let stretchYFirst = Float(image.capInsets.top) * scale
        let stretchYSecond = Float(image.size.height - image.capInsets.bottom) * scale

        let contentBoxLeft = Float(contentInsets.left) * scale
        let contentBoxRight = Float(image.size.width - contentInsets.right) * scale
        let contentBoxTop = Float(contentInsets.top) * scale
        let contentBoxBottom = Float(image.size.height - contentInsets.bottom) * scale

        let contentBox = ImageContent(left: contentBoxLeft,
                                      top: contentBoxTop,
                                      right: contentBoxRight,
                                      bottom: contentBoxBottom)
        try addImage(image,
                     id: id,
                     sdf: sdf,
                     stretchX: [ImageStretches(first: stretchXFirst, second: stretchXSecond)],
                     stretchY: [ImageStretches(first: stretchYFirst, second: stretchYSecond)],
                     content: contentBox)
    }

    /// Removes an image from the style.
    ///
    /// - Parameter id: ID of the image to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func removeImage(withId id: String) throws {
        try handleExpected {
            return styleManager.removeStyleImage(forImageId: id)
        }
    }

    /// Checks whether an image exists.
    ///
    /// - Parameter id: The identifier of the image.
    ///
    /// - Returns: `true` if the given image exists, `false` otherwise.
    public func imageExists(withId id: String) -> Bool {
        return styleManager.hasStyleImage(forImageId: id)
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

    // MARK: - Light

    /// Sets a light on the style.
    ///
    /// - Parameter light: The `Light` that should be applied.
    ///
    /// - Throws: An error describing why the operation was unsuccessful.
    public func setLight(_ light: Light) throws {
        guard let lightDictionary = try light.toJSON() as? [String: Any] else {
            throw TypeConversionError.unexpectedType
        }

        try setLight(properties: lightDictionary)
    }

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
        try handleExpected {
            _styleManager.setStyleLightForProperties(properties)
        }
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
        try handleExpected {
            _styleManager.setStyleLightPropertyForProperty(property, value: value)
        }
    }

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> Any {
        return lightProperty(property).value
    }

    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    public func lightProperty(_ property: String) -> StylePropertyValue {
        return _styleManager.getStyleLightProperty(forProperty: property)
    }

    // MARK: - Terrain

    /// Sets a terrain on the style
    ///
    /// - Parameter terrain: The `Terrain` that should be rendered
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setTerrain(_ terrain: Terrain) throws {
        guard let terrainDictionary = try terrain.toJSON() as? [String: Any] else {
            throw TypeConversionError.unexpectedType
        }

        try setTerrain(properties: terrainDictionary)
    }

    /// Removes terrain from style if it was set.
    public func removeTerrain() {
        _styleManager.setStyleTerrainForProperties(NSNull())
    }

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
        try handleExpected {
            _styleManager.setStyleTerrainForProperties(properties)
        }
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
        try handleExpected {
            _styleManager.setStyleTerrainPropertyForProperty(property, value: value)
        }
    }

    /// Gets the value of a style terrain property.
    ///
    /// - Parameter property: Style terrain property name.
    ///
    /// - Returns: Style terrain property value.
    public func terrainProperty(_ property: String) -> Any {
        return terrainProperty(property).value
    }

    /// Gets the value of a style terrain property.
    ///
    /// - Parameter property: Style terrain property name.
    ///
    /// - Returns: Style terrain property value.
    public func terrainProperty(_ property: String) -> StylePropertyValue {
        return _styleManager.getStyleTerrainProperty(forProperty: property)
    }

    // MARK: - Atmosphere

    /// Set the atmosphere of the style
    /// - Parameter atmosphere: ``Atmosphere`` object describing the fog, space and stars.
    public func setAtmosphere(_ atmosphere: Atmosphere) throws {
        guard let atmosphereDictionary = try atmosphere.toJSON() as? [String: Any] else {
            throw TypeConversionError.unexpectedType
        }

        try setAtmosphere(properties: atmosphereDictionary)
    }

    /// Remove the atmosphere of the style. No fog, space or stars would be rendered.
    public func removeAtmosphere() throws {
        try handleExpected {
            styleManager.setStyleAtmosphereForProperties(NSNull())
        }
    }

    /// Set an explicit atmosphere properties
    ///
    /// - See Also [style-spec/fog](https://docs.mapbox.com/mapbox-gl-js/style-spec/fog/)
    ///
    /// - Parameter properties: A dictionary of style fog (aka atmosphere) properties values,
    ///     with their names as key.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setAtmosphere(properties: [String: Any]) throws {
        try handleExpected {
            styleManager.setStyleAtmosphereForProperties(properties)
        }
    }

    /// Sets the value of a style atmosphere property.
    ///
    /// - See Also [style-spec/fog](https://docs.mapbox.com/mapbox-gl-js/style-spec/fog/)
    ///
    /// - Parameter property: Style atmosphere property name.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func setAtmosphereProperty(_ property: String, value: Any) throws {
        try handleExpected {
            styleManager.setStyleAtmospherePropertyForProperty(property, value: value)
        }
    }

    /// Gets the value of a style atmosphere property.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/fog/
    ///
    /// - Parameter property: Style atmosphere property name.
    ///
    /// - Returns: Style atmosphere property value.
    public func atmosphereProperty(_ property: String) -> StylePropertyValue {
        return styleManager.getStyleAtmosphereProperty(forProperty: property)
    }

    // MARK: Model

    /// :nodoc:
    @_spi(Experimental) public func addStyleModel(modelId: String, modelUri: String) throws {
        try handleExpected {
            _styleManager.addStyleModel(forModelId: modelId, modelUri: modelUri)
        }
    }

    // MARK: - Custom geometry

    /// Adds a custom geometry to be used in the style.
    ///
    /// To add the data, implement the fetchTileFunction callback in the options
    /// and call `setCustomGeometrySourceTileData`.
    ///
    /// - Parameters:
    ///   - id: Style source identifier
    ///   - options: Settings for the custom geometry
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addCustomGeometrySource(withId id: String, options: CustomGeometrySourceOptions) throws {
        try handleExpected {
            return _styleManager.addStyleCustomGeometrySource(forSourceId: id, options: options)
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
    public func setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Feature]) throws {
        let mbxFeatures = features.compactMap { MapboxCommon.Feature($0) }
        try handleExpected {
            return _styleManager.setStyleCustomGeometrySourceTileDataForSourceId(sourceId, tileId: tileId, featureCollection: mbxFeatures)
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
        try handleExpected {
            return _styleManager.invalidateStyleCustomGeometrySourceTile(forSourceId: sourceId, tileId: tileId)
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
        try handleExpected {
            return _styleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId: sourceId, bounds: bounds)
        }
    }
}

// MARK: - Conversion helpers

internal func handleExpected<Value, Error>(closure: () -> (Expected<Value, Error>)) throws {
    let expected = closure()

    if expected.isError() {
        // swiftlint:disable force_cast
        throw StyleError(message: expected.error as! String)
        // swiftlint:enable force_cast
    }
}

internal func handleExpected<Value, Error, ReturnType>(closure: () -> (Expected<Value, Error>)) throws -> ReturnType {
    let expected = closure()

    if expected.isError() {
        // swiftlint:disable force_cast
        throw StyleError(message: expected.error as! String)
        // swiftlint:enable force_cast
    }

    guard let result = expected.value as? ReturnType else {
        assertionFailure("Unexpected type mismatch. Type: \(String(describing: expected.value)) expect \(ReturnType.self)")
        throw TypeConversionError.unexpectedType
    }

    return result
}

// swiftlint:enable type_body_length

// MARK: - Attribution -

extension Style {
    internal func sourceAttributions() -> [String] {
        return allSourceIdentifiers.compactMap {
            sourceProperty(for: $0.id, property: "attribution").value as? String
        }
    }
}

// MARK: - StyleProjection

extension Style {
    /// Sets the projection.
    ///
    /// - Parameter projection: The ``StyleProjection`` to apply to the style.
    /// - Throws: ``StyleError`` if the projection could not be applied.
    public func setProjection(_ projection: StyleProjection) throws {
        let expected = _styleManager.setStyleProjectionPropertyForProperty(
            StyleProjection.CodingKeys.name.rawValue,
            value: projection.name.rawValue)
        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// The current projection.
    public var projection: StyleProjection {
        let projectionName = _styleManager.getStyleProjectionProperty(
            forProperty: StyleProjection.CodingKeys.name.rawValue)
        if projectionName.kind == .undefined {
            return StyleProjection(name: .mercator)
        } else {
            // swiftlint:disable:next force_cast
            return StyleProjection(name: StyleProjectionName(rawValue: projectionName.value as! String)!)
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
