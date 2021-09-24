import Foundation

// swiftlint:disable file_length function_parameter_count
internal protocol StyleManagerProtocol {
    /// `true` if and only if the style JSON contents, the style specified sprite
    /// and sources are all loaded, otherwise returns `false`.
    var isLoaded: Bool { get }

    /// Get or set the style URI
    ///
    /// Setting a new style is asynchronous. In order to get the result of this
    /// operation, listen to `MapEvents.styleDataLoaded`, `MapEvents.styleLoaded`.
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    var uri: StyleURI? { get set }

    /// Get or set the style via a JSON serialization string
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    var JSON: String { get set }

    /// The map style's default camera, if any, or a default camera otherwise.
    /// The map style default camera is defined as follows:
    ///
    /// - [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center)
    /// - [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-zoom)
    /// - [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing)
    /// - [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch)
    ///
    /// The style default camera is re-evaluated when a new style is loaded.
    var defaultCamera: CameraOptions { get }

    /// Get or set the map style's transition options.
    ///
    /// By default, the style parser will attempt to read the style default
    /// transition options, if any, falling back to an immediate transition
    /// otherwise.
    ///
    /// The style transition is re-evaluated when a new style is loaded.
    ///
    /// - Attention:
    ///     Overridden transition options are reset once a new style has been loaded.
    var transition: TransitionOptions { get set }

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
    func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws

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
    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws

    /// Returns `true` if the id passed in is associated to a persistent layer
    /// - Parameter id: The layer identifier to test
    func isPersistentLayer(id: String) throws -> Bool

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
    func addPersistentCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws

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
    func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws

    /// Removes an existing style layer
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - Parameter id: Identifier of the style layer to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func removeLayer(withId id: String) throws

    /// Checks whether a given style layer exists.
    ///
    /// Runtime style layers are valid until they are either removed or a new
    /// style is loaded.
    ///
    /// - Parameter id: Style layer identifier.
    ///
    /// - Returns: `true` if the given style layer exists, `false` otherwise.
    func layerExists(withId id: String) -> Bool

    /// The ordered list of the current style layers' identifiers and types
    var allLayerIdentifiers: [LayerInfo] { get }

    /// :nodoc:
    ///
    /// Gets the value of style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The value of the property in the layer with layerId.
    func layerProperty(for layerId: String, property: String) -> StylePropertyValue

    /// Sets a JSON value to a style layer property.
    ///
    /// - Parameters:
    ///   - layerId: Style layer identifier.
    ///   - property: Style layer property name.
    ///   - value: Style layer property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setLayerProperty(for layerId: String, property: String, value: Any) throws

    /// :nodoc:
    ///
    /// Gets the default value of style layer property.
    ///
    /// - Parameters:
    ///   - layerType: Style layer type.
    ///   - property: Style layer property name.
    ///
    /// - Returns:
    ///     The default value of the property for the layers with type layerType.
    static func layerPropertyDefaultValue(for layerType: LayerType, property: String) -> StylePropertyValue

    /// Gets the properties for a style layer.
    ///
    /// - Parameter layerId: layer id.
    ///
    /// - Returns:
    ///     JSON dictionary representing the layer properties
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func layerProperties(for layerId: String) throws -> [String: Any]

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
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws

    // MARK: Sources

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
    func addSource(withId sourceId: String, properties: [String: Any]) throws

    /// Removes an existing style source.
    ///
    /// - Parameter sourceId: Identifier of the style source to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func removeSource(withId sourceId: String) throws

    /// Checks whether a given style source exists.
    ///
    /// - Parameter sourceId: Style source identifier.
    ///
    /// - Returns: `true` if the given source exists, `false` otherwise.
    func sourceExists(withId sourceId: String) -> Bool

    /// The ordered list of the current style sources' identifiers and types
    var allSourceIdentifiers: [SourceInfo] { get }

    // MARK: Source properties

    /// :nodoc:
    ///
    /// Gets the value of style source property.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - property: Style source property name.
    ///
    /// - Returns: The value of the property in the source with sourceId.
    func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue

    /// Sets a value to a style source property.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - property: Style source property name.
    ///   - value: Style source property value (JSON value)
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws

    /// Gets style source properties.
    ///
    /// - Parameter sourceId: Style source identifier
    ///
    /// - Returns:
    ///     JSON dictionary representing the layer properties
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func sourceProperties(for sourceId: String) throws -> [String: Any]

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
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws

    /// :nodoc:
    ///
    /// Gets the default value of style source property.
    ///
    /// - Parameters:
    ///   - sourceType: Style source type.
    ///   - property: Style source property name.
    ///
    /// - Returns:
    ///     The default value for the named property for the sources with type sourceType.
    static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue

    // MARK: Image source

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
    func updateImageSource(withId sourceId: String, image: UIImage) throws

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
    func addImage(_ image: UIImage,
                  id: String,
                  sdf: Bool,
                  stretchX: [ImageStretches],
                  stretchY: [ImageStretches],
                  content: ImageContent?) throws

    /// Removes an image from the style.
    ///
    /// - Parameter id: ID of the image to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func removeImage(withId id: String) throws

    /// Get an image from the style.
    ///
    /// - Parameter id: ID of the image.
    ///
    /// - Returns: UIImage representing the data associated with the given ID,
    ///     or nil if no image is associated with that ID.
    func image(withId id: String) -> UIImage?

    // MARK: Light

    /// Sets the style global light source properties.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#light
    ///
    /// - Parameter properties: A dictionary of style light properties values,
    ///     with their names as key.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setLight(properties: [String: Any]) throws

    /// :nodoc:
    ///
    /// Gets the value of a style light property.
    ///
    /// - Parameter property: Style light property name.
    ///
    /// - Returns: Style light property value.
    func lightProperty(_ property: String) -> StylePropertyValue

    /// Sets a value to the style light property.
    ///
    /// - Parameters:
    ///   - property: Style light property name.
    ///   - value: Style light property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setLightProperty(_ property: String, value: Any) throws

    // MARK: Terrain

    /// Sets the style global terrain source properties.
    ///
    /// - See Also: https://docs.mapbox.com/mapbox-gl-js/style-spec/#terrain
    ///
    /// - Parameter properties: A dictionary of style terrain properties values,
    ///     with their names as key.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setTerrain(properties: [String: Any]) throws

    /// Gets the value of a style terrain property.
    ///
    /// - Parameter property: Style terrain property name.
    ///
    /// - Returns: Style terrain property value.
    func terrainProperty(_ property: String) -> StylePropertyValue

    /// Sets a value to the named style terrain property.
    ///
    /// - Parameters:
    ///   - property: Style terrain property name.
    ///   - value: Style terrain property value.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setTerrainProperty(_ property: String, value: Any) throws

    // MARK: Custom geometry

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
    func addCustomGeometrySource(withId sourceId: String, options: CustomGeometrySourceOptions) throws

    /// :nodoc:
    /// 
    /// Set tile data of a custom geometry.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - tileId: Identifier of the tile
    ///   - features: An array of features to add
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Turf.Feature]) throws

    /// Invalidate tile for provided custom geometry source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - tileId: Identifier of the tile
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func invalidateCustomGeometrySourceTile(forSourceId sourceId: String, tileId: CanonicalTileID) throws

    /// Invalidate region for provided custom geometry source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - bounds: Coordinate bounds.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    func invalidateCustomGeometrySourceRegion(forSourceId sourceId: String, bounds: CoordinateBounds) throws
}
// swiftlint:enable file_length function_parameter_count
