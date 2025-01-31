// swiftlint:disable file_length
@_implementationOnly import MapboxCommon_Private
import UIKit

protocol StyleProtocol: AnyObject {
    var isStyleLoaded: Bool { get }
    var isStyleRootLoaded: Signal<Bool> { get }
    var styleDefaultCamera: CameraOptions { get }
    var uri: StyleURI? { get set }
    var mapStyle: MapStyle? { get set }
    func setMapContent(_ content: () -> any MapContent)
    func setMapContentDependencies(_ dependencies: MapContentDependencies)
    func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws
    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func moveLayer(withId id: String, to position: LayerPosition) throws
    func removeLayer(withId id: String) throws
    func layerExists(withId id: String) -> Bool
    func layerProperties(for layerId: String) throws -> [String: Any]
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws
    func setLayerProperty(for layerId: String, property: String, value: Any) throws

    func addSource(_ source: Source, dataId: String?) throws
    func removeSource(withId id: String) throws
    func sourceExists(withId id: String) -> Bool
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String?)
    func addGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String?)
    func updateGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String?)
    func removeGeoJSONSourceFeatures(forSourceId sourceId: String, featureIds: [String], dataId: String?)

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
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String? = nil) {
        updateGeoJSONSource(withId: id, geoJSON: geoJSON, dataId: dataId)
    }
    func addSource(_ source: Source, dataId: String? = nil)  throws {
        try addSource(source, dataId: dataId)
    }
}

// swiftlint:disable type_body_length

/// Style manager is a base class for ``MapboxMap`` and ``Snapshotter`` that provides provides methods to manipulate Map Style at runtime.
///
/// Use style manager to dynamically modify the map style. You can manage layers, sources, lights, terrain, and many more.
/// Typically, you don’t create the style manager instances yourself. Instead you receive instance of this class from ``MapView`` as the ``MapView/mapboxMap`` property, or create an instance of ``Snapshotter``.
///
/// To load the style use ``styleURI`` or ``styleJSON`` or ``mapStyle`` property. The latter
/// allows not only load the style, but also modify the style configuration, for more information, see ``MapStyle``.
///
/// - Important: `StyleManager` should only be used from the main thread.
public class StyleManager {
    private let sourceManager: StyleSourceManagerProtocol
    private let styleManager: StyleManagerProtocol
    private let styleReconciler: MapStyleReconciler
    private let contentReconciler: AnyObject?

    init(with styleManager: StyleManagerProtocol, sourceManager: StyleSourceManagerProtocol) {
        self.sourceManager = sourceManager
        self.styleManager = styleManager
        self.styleReconciler = MapStyleReconciler(styleManager: styleManager)
        self.contentReconciler = MapContentReconciler(
            styleManager: styleManager,
            sourceManager: sourceManager,
            styleIsLoaded: styleReconciler.isStyleRootLoaded
        )
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
        if let customLayer = layer as? CustomLayer {
            return try addCustomLayer(customLayer, persistent: false, layerPosition: layerPosition)
        }
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
        if let customLayer = layer as? CustomLayer {
            return try addCustomLayer(customLayer, persistent: true, layerPosition: layerPosition)
        }
        // Attempt to encode the provided layer into a dictionary and apply it to the map.
        let layerProperties = try layer.allStyleProperties()
        try addPersistentLayer(with: layerProperties, layerPosition: layerPosition)
    }

    internal func addCustomLayer(_ customLayer: CustomLayer, persistent: Bool, layerPosition: LayerPosition? = nil) throws {
        guard (customLayer.renderer as? EmptyCustomRenderer)?.shouldWarnBeforeUsage != true else {
            throw StyleError(message: """
                No renderer assigned to the custom layer [id=\(customLayer.id)].
                Create a new layer with CustomLayer.init(id:renderer:))
                """)
        }

        if persistent {
            try addPersistentCustomLayer(
                withId: customLayer.id,
                layerHost: customLayer.renderer,
                layerPosition: layerPosition
            )
        } else {
            try addCustomLayer(
                withId: customLayer.id,
                layerHost: customLayer.renderer,
                layerPosition: layerPosition
            )
        }

        let layerProperties = try customLayer.allStyleProperties()
        try setLayerProperties(for: customLayer.id, properties: layerProperties)
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

     - Parameter id: The id of the layer to be fetched
     - Returns: The fully formed `layer` object.
     - Throws: Type conversion errors
     */
    public func layer(withId id: String) throws -> Layer {
        // Get the layer properties from the map
        let properties = try layerProperties(for: id)

        guard let typeString = properties["type"] as? String,
              let type = LayerType(rawValue: typeString).layerType else {
            throw TypeConversionError.invalidObject
        }

        return try type.init(jsonObject: properties)
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
                result[key] = Self.layerPropertyDefaultValue(for: layer.type, property: key).value
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
     - Parameter dataId: An optional data ID to filter ``MapboxMap/onSourceDataLoaded`` to only the specified data source. Applies only to ``GeoJSONSource``s.

     - Throws: ``StyleError`` if there is a problem adding the `source`.
     */
    public func addSource(_ source: Source, dataId: String? = nil) throws {
        try sourceManager.addSource(source, dataId: dataId)
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

    /// Updates the ``GeoJSONSource/data`` property of a given ``GeoJSONSource`` with a new value.
    ///
    /// - Parameters:
    ///   - id: The identifier representing the GeoJSON source.
    ///   - data: The new data to be associated with the source.
    ///   - dataId: An optional data ID to filter ``MapboxMap/onSourceDataLoaded`` to only the specified data source.
    ///
    /// The update will be scheduled and applied on a GeoJSON serialization queue.
    ///
    /// In order to capture events when actual data is drawn on the map please refer to Events API
    /// and listen to `onSourceDataLoaded` (optionally pass the `dataId` parameter to filter the events)
    /// or `onMapLoadingError` with `type = metadata` if data parsing error has occurred.
    ///
    /// - Attention: This method is only effective with sources of `GeoJSONSource`
    /// type, and cannot be used to update other source types.
    public func updateGeoJSONSource(withId id: String, data: GeoJSONSourceData, dataId: String? = nil) {
        sourceManager.updateGeoJSONSource(withId: id, data: data, dataId: dataId)
    }

    /// Updates the ``GeoJSONSource/data`` property of a given ``GeoJSONSource`` with a new value of `GeoJSONObject`.
    ///
    /// - Parameters:
    ///   - id: The identifier representing the GeoJSON source.
    ///   - geoJSON: The new GeoJSON to be associated with the source data. i.e.
    ///   a feature or feature collection.
    ///   - dataId: An optional data ID to filter ``MapboxMap/onSourceDataLoaded`` to only the specified data source.
    ///
    /// The update will be scheduled and applied on a GeoJSON serialization queue.
    ///
    /// In order to capture events when actual data is drawn on the map please refer to Events API
    /// and listen to `onSourceDataLoaded` (optionally pass the `dataId` parameter to filter the events)
    /// or `onMapLoadingError` with `type = metadata` if data parsing error has occurred.
    ///
    /// - Attention: This method is only effective with sources of `GeoJSONSource`
    /// type, and cannot be used to update other source types.
    public func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String? = nil) {
        updateGeoJSONSource(withId: id, data: geoJSON.sourceData, dataId: dataId)
    }

    /// Add additional features to a GeoJSON style source.
    ///
    /// The add operation will be scheduled and applied on a GeoJSON serialization queue.
    ///
    /// In order to capture events when actual data is drawn on the map please refer to Events API
    /// and listen to `onSourceDataLoaded` (optionally pass the `dataId` parameter to filter the events)
    /// or `onMapLoadingError` with `type = metadata` if data parsing error has occurred.
    ///
    /// Partially updating a GeoJSON source is not compatible with using shared cache and generated IDs.
    /// It is important to ensure that every feature in the GeoJSON style source, as well as the newly added
    /// feature, has a unique ID (or a unique promote ID if in use). Failure to provide unique IDs will result
    /// in a `map-loading-error`.
    ///
    /// - Note: The method allows the user to provide a data ID, which will be returned as the `dataId` parameter in the
    /// `source-data-loaded` event. However, it's important to note that multiple partial updates can be queued
    /// for the same GeoJSON source when ongoing source parsing is taking place. In these cases, the partial
    /// updates will be applied to the source in batches. Only the data ID provided in the most recent call within
    /// each batch will be included in the `source-data-loaded` event. If no data ID is provided in the most recent
    /// call, the data ID in the `source-data-loaded`event will be null.
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the style source.
    ///   - features: An array of GeoJSON features to be added to the source.
    ///   - dataId: An arbitrary string used to track the given GeoJSON data.
    /// - Throws: ``StyleError`` if there is a problem adding features to the source.
    public func addGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String? = nil) {
        sourceManager.addGeoJSONSourceFeatures(forSourceId: sourceId, features: features, dataId: dataId)
    }

    /// Update existing features in a GeoJSON style source.
    ///
    /// The update operation will be scheduled and applied on a GeoJSON serialization queue.
    ///
    /// In order to capture events when actual data is drawn on the map please refer to Events API
    /// and listen to `onSourceDataLoaded` (optionally pass the `dataId` parameter to filter the events)
    /// or `onMapLoadingError` with `type = metadata` if data parsing error has occurred.
    ///
    /// Partially updating a GeoJSON source is not compatible with using shared cache and generated IDs.
    /// It is important to ensure that every feature in the GeoJSON style source, as well as the newly added
    /// feature, has a unique ID (or a unique promote ID if in use). Failure to provide unique IDs will result
    /// in a `map-loading-error`.
    ///
    /// - Note: The method allows the user to provide a data ID, which will be returned as the `dataId` parameter in the
    /// `source-data-loaded` event. However, it's important to note that multiple partial updates can be queued
    /// for the same GeoJSON source when ongoing source parsing is taking place. In these cases, the partial
    /// updates will be applied to the source in batches. Only the data ID provided in the most recent call within
    /// each batch will be included in the `source-data-loaded` event. If no data ID is provided in the most recent
    /// call, the data ID in the `source-data-loaded`event will be null.
    /// - Parameters:
    ///   - sourceId: A style source identifier.
    ///   - features: The GeoJSON features to be updated in the source.
    ///   - dataId: An arbitrary string used to track the given GeoJSON data.
    /// - Throws: ``StyleError`` if there is a problem updating features in the source.
    public func updateGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String? = nil) {
        sourceManager.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: features, dataId: dataId)
    }

    /// Remove features from a GeoJSON style source.
    ///
    /// The remove operation will be scheduled and applied on a GeoJSON serialization queue.
    ///
    /// In order to capture events when actual data is drawn on the map please refer to Events API
    /// and listen to `onSourceDataLoaded` (optionally pass the `dataId` parameter to filter the events)
    /// or `onMapLoadingError` with `type = metadata` if an error has occurred.
    ///
    /// Partially updating a GeoJSON source is not compatible with using shared cache and generated IDs.
    /// It is important to ensure that every feature in the GeoJSON style source, as well as the newly added
    /// feature, has a unique ID (or a unique promote ID if in use). Failure to provide unique IDs will result
    /// in a `map-loading-error`.
    ///
    /// - Note: The method allows the user to provide a data ID, which will be returned as the `dataId` parameter in the
    /// `source-data-loaded` event. However, it's important to note that multiple partial updates can be queued
    /// for the same GeoJSON source when ongoing source parsing is taking place. In these cases, the partial
    /// updates will be applied to the source in batches. Only the data ID provided in the most recent call within
    /// each batch will be included in the `source-data-loaded` event. If no data ID is provided in the most recent
    /// call, the data ID in the `source-data-loaded`event will be null.
    /// - Parameters:
    ///   - sourceId: A style source identifier.
    ///   - featureIds: The Ids of the features that need to be removed from the source.
    ///   - dataId: An arbitrary string used to track the given GeoJSON data.
    /// - Throws: ``StyleError`` if there is a problem removing features from the source.
    public func removeGeoJSONSourceFeatures(forSourceId sourceId: String, featureIds: [String], dataId: String? = nil) {
        sourceManager.removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: featureIds, dataId: dataId)
    }

    /// `true` if and only if the style JSON contents, the style specified sprite,
    /// and sources are all loaded, otherwise returns `false`.
    public var isStyleLoaded: Bool {
        return styleManager.isStyleLoaded()
    }

    var isStyleRootLoaded: Signal<Bool> { styleReconciler.isStyleRootLoaded }

    /// MapStyle represents style configuration to load the style.
    ///
    /// It comprises from a StyleURI or style JSON complemented by style import configuration.
    public var mapStyle: MapStyle? {
        get { styleReconciler.mapStyle }
        set { styleReconciler.mapStyle = newValue }
    }

    /// Sets style content to the map.
    ///
    /// Use this method to declaratively specify which runtime styling components will be added to the style.
    ///
    /// ```swift
    /// let mapView = MapView()
    /// mapView.mapboxMap.setMapStyleContent {
    ///     VectorSource(id: "traffic-source")
    ///         .tiles(["traffic-tiles-url"])
    ///     LineLayer(id: "traffic-layer", source: "traffic-source")
    ///         .lineColor(.red)
    /// }
    /// ```
    ///
    /// - Note: Don't wait until the style is loaded, it is safe to set style content just when the map is created.
    ///
    /// Call this method whenever the app state changes, the style will be modified incrementally.
    /// The style content is unique per map, make sure that all the styling components
    /// you need are in the style content upon every call.
    ///
    /// ```swift
    /// func onMapStateChanged(_ state: State) {
    ///   mapView.mapboxMap.setMapStyleContent {
    ///     if state.displayTraffic {
    ///         VectorSource(id: "traffic-source")
    ///             .tiles(["traffic-tiles-url"])
    ///         LineLayer(id: "traffic-layer", source: "traffic-source")
    ///             .lineColor(state.trafficColor)
    ///     }
    /// }
    /// ```
    ///
    /// - Warning: Avoid having strong references to `MapboxMap` or `MapView` in your custom content as it will lead to strong reference cycles.
    ///
    /// See more information in the <doc:Declarative-Map-Styling>.
    public func setMapStyleContent(@MapStyleContentBuilder content: () -> some MapStyleContent) {
        setMapContent({
            MapStyleContentAdapter(content())
        })
    }

    func setMapContent(_ content: () -> any MapContent) {
        if let contentReconciler = contentReconciler as? MapContentReconciler {
            contentReconciler.content = content()
        }
    }

    func setMapContentDependencies(_ dependencies: MapContentDependencies) {
        if let contentReconciler = contentReconciler as? MapContentReconciler {
            contentReconciler.setMapContentDependencies(dependencies)
        }
    }

    /// Get or set the style URI
    ///
    /// Setting a new style is asynchronous. In order to get the result of this
    /// operation, listen to `MapEvents.styleDataLoaded`, `MapEvents.styleLoaded`.
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    public var styleURI: StyleURI? {
        get {
            let uriString = styleManager.getStyleURI()

            // A "nil" style is returned as an empty string
            if uriString.isEmpty {
                return nil
            }

            return StyleURI(rawValue: uriString)
        }
        set {
            if let newValue {
                styleReconciler.mapStyle = MapStyle(uri: newValue)
            }
        }
    }

    /// Get or set the style via a JSON serialization string
    ///
    /// - Attention:
    ///     This method should be called on the same thread where the MapboxMap
    ///     object is initialized.
    public var styleJSON: String {
        get { styleManager.getStyleJSON() }
        set { styleReconciler.mapStyle = MapStyle(json: newValue) }
    }

    /// Loads ``MapStyle``, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// If style loading started while the other style is already loading, the latter's loading `completion`
    /// will receive a ``CancelError``. If a style is failed to load, `completion` will receive a ``StyleError``.
    ///
    /// - Parameters:
    ///   - mapStyle: A style to load.
    ///   - transition: Options for the style transition.
    ///   - completion: Closure called when the style has been fully loaded.
    public func load(mapStyle: MapStyle,
                     transition: TransitionOptions? = nil,
                     completion: ((Error?) -> Void)? = nil) {
        styleReconciler.loadStyle(mapStyle, transition: transition, completion: completion)
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
    public var styleDefaultCamera: CameraOptions {
        return CameraOptions(styleManager.getStyleDefaultCamera())
    }

    /// Get or set the map `style`'s transition options.
    ///
    /// By default, the style parser will attempt to read the style default
    /// transition, if any, falling back to a 0.3 s transition otherwise.
    ///
    /// Overridden transitions are reset once a new style has been loaded.
    /// To customize the transition used when switching styles, set this
    /// property after `MapEvents.Event.styleDataLoaded` where
    /// `payload type == "style"` and before
    /// `MapEvents.Event.styleDataLoaded` where `payload type == "sprite"`
    /// and where `payload type == "sources"`.
    /// - SeeAlso: ``MapboxMap/onNext(event:handler:)``
    public var styleTransition: TransitionOptions {
        get {
            TransitionOptions(styleManager.getStyleTransition())
        }
        set {
            styleManager.setStyleTransitionFor(newValue.coreOptions)
        }
    }

    /// Returns the list containing information about existing style import objects.
    public var styleImports: [StyleObjectInfo] {
        return styleManager.getStyleImports()
    }

    /// Gets the style import schema.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import.
    ///
    ///  - Returns:
    ///   - The style import schema, containing the default configurations for the style import,
    ///           or a string describing an error if the operation was not successful.
    ///  - Throws:
    ///   - A StyleError or decoding error if the operation was not successful.
    public func getStyleImportSchema(for importId: String) throws -> Any {
        try handleExpected {
            return styleManager.getStyleImportSchema(forImportId: importId)
        }
    }

    /// Gets style import config.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import.
    ///
    ///  - Returns:
    ///   - The style import configuration or a string describing an error if the operation was not successful.
    public func getStyleImportConfigProperties(for importId: String) throws -> [String: StylePropertyValue] {
        try handleExpected {
            return styleManager.getStyleImportConfigProperties(forImportId: importId)
        }
    }

    /// Gets the value of style import config.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import.
    ///   - config: The style import config name.
    ///
    ///  - Returns:
    ///   - The style import configuration or a string describing an error if the operation was not successful.
    public func getStyleImportConfigProperty(for importId: String, config: String) throws -> StylePropertyValue {
        try handleExpected {
            return styleManager.getStyleImportConfigProperty(forImportId: importId, config: config)
        }
    }

    /// Sets style import config.
    /// This method can be used to perform batch update for a style import configurations.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import.
    ///   - configs: A map of style import configurations.
    ///
    ///  - Throws:
    ///   - A string describing an error if the operation was not successful.
    public func setStyleImportConfigProperties(for importId: String, configs: [String: Any]) throws {
        try handleExpected {
            return styleManager.setStyleImportConfigPropertiesForImportId(importId, configs: configs)
        }
    }

    /// Sets a value to a style import config.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import.
    ///   - config: The style import config name.
    ///   - value: The style import config value.
    ///
    ///  - Throws:
    ///   - A string describing an error if the operation was not successful.
    public func setStyleImportConfigProperty(for importId: String, config: String, value: Any) throws {
        try handleExpected {
            return styleManager.setStyleImportConfigPropertyForImportId( importId, config: config, value: value)
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
            return styleManager.addStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Moves a style layer with given `layerId` to the new position.
    ///
    /// - Parameters:
    ///   - id: Style layer id
    ///   - position: Position to move the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     `StyleError` on failure, or `NSError` with a _domain of "com.mapbox.bindgen"
    public func moveLayer(withId id: String, to position: LayerPosition) throws {
        try handleExpected {
            styleManager.moveStyleLayer(forLayerId: id, layerPosition: position.corePosition)
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
            return styleManager.addPersistentStyleLayer(forProperties: properties, layerPosition: layerPosition?.corePosition)
        }
    }

    /// Returns `true` if the id passed in is associated to a persistent layer
    /// - Parameter id: The layer identifier to test
    public func isPersistentLayer(id: String) throws -> Bool {
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
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addPersistentCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        try handleExpected {
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
    ///   - layerPosition: Position to add the layer in the stack of layers on the map. Defaults to the top layer.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    public func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws {
        try handleExpected {
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
        try handleExpected {
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

    /// The ordered list of the current style slots identifiers
    public var allSlotIdentifiers: [Slot] {
        styleManager.getStyleSlots().compactMap(Slot.init)
    }

    /// The ordered list of the current style layers' identifiers and types
    public var allLayerIdentifiers: [LayerInfo] {
        styleManager.getStyleLayers().map { info in
            LayerInfo(id: info.id, type: LayerType(rawValue: info.type))
        }
    }

    /// The ordered list of the current style imports' identifiers
    var allImportIdentifiers: [String] {
        styleManager.getStyleImports().map(\.id)
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
        try handleExpected {
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
        return CoreStyleManager.getStyleLayerPropertyDefaultValue(forLayerType: layerType.rawValue, property: property)
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
        try handleExpected {
            return styleManager.setStyleLayerPropertiesForLayerId(layerId, properties: properties)
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

    /// The ordered list of the current style sources' identifiers and types.
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
        guard let mbmImage = CoreMapsImage(uiImage: image) else {
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
        guard let mbmImage = CoreMapsImage(uiImage: image) else {
            throw TypeConversionError.unexpectedType
        }

        try handleExpected {
            return styleManager.addStyleImage(forImageId: id,
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
        let imageProperties = ImageProperties(uiImage: image, contentInsets: contentInsets, id: id, sdf: sdf)

        try addImage(image,
                     id: id,
                     sdf: sdf,
                     stretchX: [ImageStretches(first: imageProperties.stretchXFirst, second: imageProperties.stretchXSecond)],
                     stretchY: [ImageStretches(first: imageProperties.stretchYFirst, second: imageProperties.stretchYSecond)],
                     content: imageProperties.contentBox)
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

        return UIImage(mbmImage: mbmImage)
    }

    // MARK: - Lights

    /// The ordered list of the current style lights' identifiers and types
    public var allLightIdentifiers: [LightInfo] {
        return styleManager.getStyleLights().map { info in
            LightInfo(id: info.id, type: LightType(rawValue: info.type))
        }
    }

    /// Gets the value of a style light property.
    ///
    /// - Parameter lightId: The unique identifier of the style light in lights list.
    /// - Parameter property: The style light property name.
    public func lightProperty(for lightId: String, property: String) -> Any {
        styleManager.getStyleLightProperty(forId: lightId, property: property).value
    }

    /// Gets the value of a style light property.
    ///
    /// - Parameter lightId: The unique identifier of the style light in lights list.
    /// - Parameter property: The style light property name.
    public func lightPropertyValue(for lightId: String, property: String) -> StylePropertyValue {
        styleManager.getStyleLightProperty(forId: lightId, property: property)
    }

    /// Set global directional lightning.
    /// - Parameter flatLight: The flat light source.
    public func setLights(_ flatLight: FlatLight) throws {
        try styleManager.setLights(flatLight)
    }

    /// Set dynamic lightning.
    /// - Parameters:
    ///   - ambientLight: The ambient light source.
    ///   - directionalLight: The directional light source.
    public func setLights(ambient ambientLight: AmbientLight, directional directionalLight: DirectionalLight) throws {
        try styleManager.setLights(ambient: ambientLight, directional: directionalLight)
    }

    /// Sets the value of a style light property in lights list.
    ///
    /// - Parameter lightId: The unique identifier of the style light in lights list.
    /// - Parameter property: The style light property name.
    /// - Parameter value: The style light property value.
    /// - throws: An error describing why the operation is unsuccessful.
    public func setLightProperty(for lightId: String, property: String, value: Any) throws {
        try handleExpected {
            styleManager.setStyleLightPropertyForId(lightId, property: property, value: value)
        }
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
        styleManager.setStyleTerrainForProperties(NSNull())
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
            styleManager.setStyleTerrainForProperties(properties)
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
            styleManager.setStyleTerrainPropertyForProperty(property, value: value)
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
        return styleManager.getStyleTerrainProperty(forProperty: property)
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
    /// - Parameter value: Style atmosphere property value.
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

    /// Adds a model to be used in the style. This API can also be used for updating
    /// a model. If the model for a given `modelId` was already added, it gets replaced by the new model.
    ///
    /// The model can be used in `model-id` property in model layer.
    ///
    /// - Parameters:
    ///    - modelId: An identifier of the model.
    ///    - modelUri: A URI for the model.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    @_documentation(visibility: public)
    @_spi(Experimental) public func addStyleModel(modelId: String, modelUri: String) throws {
        try handleExpected {
            styleManager.addStyleModel(forModelId: modelId, modelUri: modelUri)
        }
    }

    /// Removes a model from the style.
    ///
    /// - Parameters:
    ///    - modelId: The identifier of the model to remove.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    @_documentation(visibility: public)
    @_spi(Experimental) public func removeStyleModel(modelId: String) throws {
        try handleExpected {
            styleManager.removeStyleModel(forModelId: modelId)
        }
    }

    /// Checks whether a model exists.
    ///
    /// - Parameters:
    ///    - modelId: The identifier of the model.
    ///
    /// - Returns:
    ///     True if model exists, false otherwise.
    @_documentation(visibility: public)
    @_spi(Experimental) public func hasStyleModel(modelId: String) -> Bool {
        return styleManager.hasStyleModel(forModelId: modelId)
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
    public func setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Feature]) throws {
        let mbxFeatures = features.compactMap { MapboxCommon.Feature($0) }
        try handleExpected {
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
        try handleExpected {
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
        try handleExpected {
            return styleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId: sourceId, bounds: bounds)
        }
    }

    /// Note! This is an experimental feature. It can be changed or removed in future versions.
    /// Adds a custom raster source to be used in the style. To add the data, implement the `fetchTileFunction`
    /// callback in the options and call `setCustomRasterSourceTileData(forSourceId:tileId:image:)`.
    /// Note: Functions provided in `CustomRasterSourceOptions` for fetching & cancelling tiles are executed on worker threads.
    ///
    /// - Parameters:
    ///   - sourceId: A Style source identifier
    ///   - options: The `custom raster source options` for the custom raster source.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    @_spi(Experimental) public func addCustomRasterSource(forSourceId sourceId: String, options: CustomRasterSourceOptions) throws {
        try handleExpected {
            return styleManager.addStyleCustomRasterSource(forSourceId: sourceId, options: options)
        }
    }

    /// Note! This is an experimental feature. It can be changed or removed in future versions.
    /// Set tile data for raster tiles.
    ///
    /// The provided data is not cached, and the implementation will call the fetch callback each time the tile reappears.
    ///
    /// - Parameters:
    ///   - sourceId: A Style source identifier
    ///   - tiles: tiles Array with new tile data.
    ///
    /// - Throws:
    ///     An error describing why the operation was unsuccessful.
    @_spi(Experimental) public func setCustomRasterSourceTileData(forSourceId sourceId: String, tiles: [CustomRasterSourceTileData]) throws {
        try handleExpected {
            return styleManager.setStyleCustomRasterSourceTileDataForSourceId(sourceId, tiles: tiles)
        }
    }

    /// Adds style import with specified id using pre-defined Mapbox Style, or custom style bundled with the application, or over the network.
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to move
    ///   - uri: An instance of ``StyleURI`` pointing to a Mapbox Style URI (mapbox://styles/{user}/{style}), a full HTTPS URI, or a path to a local file.
    ///   - config: Style import configuration to be applied on style load.
    ///   - importPosition: Position at which import will be added in the imports stack. By default it will be added above everything.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func addStyleImport(withId id: String, uri: StyleURI, config: [String: Any]? = nil, importPosition: ImportPosition? = nil) throws {
        try handleExpected {
            return styleManager.addStyleImportFromURI(forImportId: id, uri: uri.rawValue, config: config, importPosition: importPosition?.corePosition)
        }
    }

    /// Adds style import with specified id using style JSON string and configuration.
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to move
    ///   - json: Style JSON conforming to [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/).
    ///   - config: Style import configuration to be applied on style load.
    ///   - importPosition: Position at which import will be added in the imports stack. By default it will be added above everything.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func addStyleImport(withId id: String, json: String, config: [String: Any]? = nil, importPosition: ImportPosition? = nil) throws {
        try handleExpected {
            return styleManager.addStyleImportFromJSON(forImportId: id, json: json, config: config, importPosition: importPosition?.corePosition)
        }
    }

    /// Updates style import with specified id using pre-defined Mapbox Style, or custom style bundled with the application, or over the network.
    ///
    /// - Important: For performance reasons, if you only need to update only configuration,  use ``StyleManager/setStyleImportConfigProperties(for:configs:)`` or ``StyleManager/setStyleImportConfigProperty(for:config:value:)```
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to move
    ///   - uri: An instance of ``StyleURI`` pointing to a Mapbox Style URI (mapbox://styles/{user}/{style}), a full HTTPS URI, or a path to a local file.
    ///   - config: Style import configuration to be applied on style load.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func updateStyleImport(withId id: String, uri: StyleURI, config: [String: Any]? = nil) throws {
        try handleExpected {
            return styleManager.updateStyleImportWithURI(forImportId: id, uri: uri.rawValue, config: config)
        }
    }

    /// Updates style import with specified id using style JSON string and configuration.
    ///
    /// - Important: For performance reasons, if you only need to update only configuration,  use ``StyleManager/setStyleImportConfigProperties(for:configs:)`` or ``StyleManager/setStyleImportConfigProperty(for:config:value:)```
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to move
    ///   - json: Style JSON conforming to [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/).
    ///   - config: Style import configuration to be applied on style load.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func updateStyleImport(withId id: String, json: String, config: [String: Any]? = nil) throws {
        try handleExpected {
            return styleManager.updateStyleImportWithJSON(forImportId: id, json: json, config: config)
        }
    }

    /// Move an existing style import to specified position in imports stack.
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to move
    ///   - position: Position in the imports stack.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func moveStyleImport(withId id: String, to position: ImportPosition) throws {
        try handleExpected {
            return styleManager.moveStyleImport(forImportId: id, importPosition: position.corePosition)
        }
    }

    /// Removes an existing style import.
    ///
    ///  - Parameters:
    ///   - id: Identifier of the style import to remove.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    public func removeStyleImport(withId id: String) throws {
        try handleExpected {
            return styleManager.removeStyleImport(forImportId: id)
        }
    }

    /// Removes an existing style import.
    ///
    ///  - Parameters:
    ///   - importId: Identifier of the style import to remove.
    ///
    ///  - Throws:
    ///   - An error describing why the operation was unsuccessful.
    @available(*, deprecated, renamed: "removeStyleImport(withId:)", message: "Please use the removeStyleImport(withId:) version.")
    public func removeStyleImport(for importId: String) throws {
        try handleExpected {
            styleManager.removeStyleImport(forImportId: importId)
        }
    }

}

extension StyleManagerProtocol {
    func setLights(_ flatLight: FlatLight) throws {
        let rawLight = try flatLight.allStyleProperties()
        try handleExpected {
            setStyleLightsForLights([rawLight])
        }
    }

    func setLights(ambient ambientLight: AmbientLight, directional directionalLight: DirectionalLight) throws {
        let rawAmbientLight = try ambientLight.allStyleProperties()
        let rawDirectionalLight = try directionalLight.allStyleProperties()
        try handleExpected {
            setStyleLightsForLights([rawAmbientLight, rawDirectionalLight])
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

// MARK: - StyleProjection

extension StyleManager {
    /// Sets the projection.
    ///
    /// - Parameter projection: The ``StyleProjection`` to apply to the style.
    /// - Throws: ``StyleError`` if the projection could not be applied.
    public func setProjection(_ projection: StyleProjection) throws {
        let projectionDictionary = try projection.allStyleProperties()
        let expected = styleManager.setStyleProjectionForProperties(projectionDictionary)

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// The current projection.
    public var projection: StyleProjection? {
        let projectionName = styleManager.getStyleProjectionProperty(
            forProperty: StyleProjection.CodingKeys.name.rawValue)
        if projectionName.kind == .undefined {
            return nil
        } else {
            // swiftlint:disable:next force_cast
            return StyleProjection(name: StyleProjectionName(rawValue: projectionName.value as! String))
        }
    }
}

// MARK: - Precipitation

extension StyleManager {
    /// Set the snow parameters to animate snowfall.
    /// ``Snow`` object can be used to set the snow parameters.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func setSnow(_ snow: Snow) throws {
        let snowDictionary = try snow.allStyleProperties()
        let expected = styleManager.setStyleSnowForProperties(snowDictionary)

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// Remove snow effect from the style.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func removeSnow() throws {
        let expected = styleManager.setStyleSnowForProperties(NSNull())

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// Set the rain parameters to animate rain drops.
    /// ``Rain`` object can be used to set the rain parameters.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func setRain(_ rain: Rain) throws {
        let rainDictionary = try rain.allStyleProperties()
        let expected = styleManager.setStyleRainForProperties(rainDictionary)

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// Remove rain effect from the style.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func removeRain() throws {
        let expected = styleManager.setStyleRainForProperties(NSNull())

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// Set color theme for style.
    /// ``ColorTheme`` is unique per style and setting a new one will effectively overwrite any previous theme.
    /// - Parameters:
    ///  - colorTheme: Color theme to apply on the style.
    /// - Throws: ``StyleError`` if the color theme could not be applied.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func setColorTheme(_ colorTheme: ColorTheme) throws {
        guard let coreTheme = colorTheme.core else {
            throw StyleError(message: "Cannot construct UIImage object.")
        }

        let expected = styleManager.setStyleColorThemeFor(coreTheme)

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }

    /// Remove color theme from the style.
    /// - Throws: ``StyleError`` if the color theme could not be removed.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func removeColorTheme() throws {
        let expected = styleManager.setStyleColorThemeFor(nil)

        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
    }
}

// MARK: - Featuresets

extension StyleManager {
    /// Returns the available featuresets in the currently loaded style.
    ///
    /// - Note: This function should only be called after the style is fully loaded; otherwise, the result may be unreliable.
    @_spi(Experimental)
    public var featuresets: [FeaturesetDescriptor<FeaturesetFeature>] {
        styleManager.getStyleFeaturesets().map(FeaturesetDescriptor<FeaturesetFeature>.init(core:))
    }
}

// MARK: - StyleTransition -

/**
 The transition property for a layer.
 A transition property controls timing for the interpolation between a
 transitionable style property's previous value and new value.
 */
public struct StyleTransition: Codable, Equatable, Sendable {

    /// Disabled style transition
    public static let zero = StyleTransition(duration: 0, delay: 0)

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

extension StyleManager: StyleProtocol {}

/// Use theme property for colors, defines whether the color will be affected by map theme or will be used as is.
@_spi(Experimental)
@_documentation(visibility: public)
public struct ColorUseTheme: Hashable, Codable, RawRepresentable, ExpressibleByStringLiteral, Sendable {
    /// Color property will be affected by currently set map theme.
    public static let `default` = ColorUseTheme(rawValue: "default")!

    /// Color property will not be affected by the map theme and will always appear exactly as specified.
    public static let none = ColorUseTheme(rawValue: "none")!

    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
