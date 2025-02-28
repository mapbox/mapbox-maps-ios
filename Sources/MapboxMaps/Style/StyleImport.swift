/// Map style import.
///
/// Imports can be used to add the contents of other styles to the current style. Instead of copying the individual layers, only the other style URL is referenced.
///
/// ``StyleImport`` is intended to be used as part of <doc:Declarative-Map-Styling>.
///
/// It's possible to put style import above the style loaded by default.
/// ```swift
/// let mapView = MapView()
///
/// mapView.mapboxMap.setMapStyleContent {
///     StyleImport(uri: StyleURI(url: "custom_style_fragment")!)
/// }
/// ```
///
///  Or you may explicitly specify empty base style and fully configure the style of the map by composing style imports.
/// ```swift
/// let mapView = MapView()
///
/// mapView.mapboxMap.mapStyle = .empty
///
/// mapView.mapboxMap.setMapStyleContent {
///     StyleImport(style: .standard(lightPreset: .dusk))
///
///     StyleImport(uri: StyleURI(url: "mapbox://custom_style_fragment")!)
/// }
/// ```
/// - Important: ``StyleImport`` encapsulates all implementation details of the style.
///              Therefore, any layers defined inside the import won't be accessible from API. More information in [v11 Migration Guide](https://docs.mapbox.com/ios/maps/guides/migrate-to-v11/#211-style-imports)
///
/// More information [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/imports)
public struct StyleImport: Sendable {
    let id: String?
    let style: MapStyle

    /// Creates a ``StyleImport`` using a Mapbox Style JSON.
    ///
    /// - Important: For the better performance with large local Style JSON please consider loading style from the file system via the ``StyleImport/init(id:uri:configuration:)`` initializer.
    ///
    /// - Parameters:
    ///   - id: Import id string, will be automatically generated if not explicitly specified.
    ///   - json: A Mapbox Style JSON string.
    ///   - configuration: Style import configurations to be applied on style load.
    public init(
        id: String? = nil,
        json: String,
        configuration: JSONObject? = nil
    ) {
        self.id = id
        self.style = MapStyle(json: json, configuration: configuration)
    }

    /// Creates a ``StyleImport`` using``StyleURI``
    ///
    /// Use this initializer to make use of pre-defined Mapbox Styles, or load a custom style bundled with the application, or over the network.
    ///
    /// - Parameters:
    ///   - id: Import id string, will be automatically generated if not explicitly specified.
    ///   - uri: An instance of ``StyleURI`` pointing to a Mapbox Style URI (mapbox://styles/{user}/{style}), a full HTTPS URI, or a path to a local file.
    ///   - configuration: Style import configuration to be applied on style load.
    public init(
        id: String? = nil,
        uri: StyleURI,
        configuration: JSONObject? = nil
    ) {
        self.id = id
        self.style = MapStyle(uri: uri, configuration: configuration)
    }

    /// Creates a ``StyleImport`` using ``MapStyle``.
    ///
    /// - Parameters:
    ///   - id: Import id string, will be automatically generated if not explicitly specified.
    ///   - style: ``MapStyle`` instance containing the URI to style or JSON comforming to [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/).
    public init(id: String? = nil, style: MapStyle) {
        self.id = id
        self.style = style
    }
}
