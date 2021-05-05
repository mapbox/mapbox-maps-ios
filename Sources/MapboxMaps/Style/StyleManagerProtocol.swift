import Foundation

public protocol StyleManagerProtocol {
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
    var uri: StyleURI { get set }

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
    var layerIdentifiers: [LayerInfo] { get }

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
    func _layerProperty(for layerId: String, property: String) -> StylePropertyValue

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
    static func _layerPropertyDefaultValue(for layerType: String, property: String) -> StylePropertyValue

    /// Gets the properties for a style layer.
    ///
    /// - Parameter layerId: layer id.
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

    // TODO: source, light, terrain, image
}
