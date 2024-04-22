import MapboxCoreMaps

/// Map style configuration.
///
/// Set map style to style manager's ``StyleManager/mapStyle`` property to load a new style, or update style import configurations when you work with ``MapView``:
///
/// ```swift
/// let mapView = MapView()
///
/// // loads Standard Mapbox Style
/// mapView.mapboxMap.mapStyle = .standard
///
/// // loads Standard Mapbox Style with Dusk light preset
/// mapView.mapboxMap.mapStyle = .standard(lightPreset: .dusk)
///
/// // loads a custom style and updates import configurations for
/// // Mapbox Standard Style imported with "my-import-id" id.
/// mapView.mapboxMap.mapStyle = MapStyle(
///     uri: StyleURI(rawValue: "https://example.com/custom-style")!
///     importConfigurations: [
///         .standard(importId: "my-import-id", lightPreset: .dusk)
///     ])
/// ```
///
/// Or use ``Map-swift.struct/mapStyle(_:)`` if you use SwiftUI ``Map-struct``. The code sample below dynamically updates the Standard Style light preset depending on the current application color scheme:
///
/// ```swift
/// struct MyView: View {
///     @Environment(\.colorScheme) var colorScheme
///     var body: some View {
///         Map()
///             .mapStyle(.standard(lightPreset: colorScheme == .light ? .day : .dusk))
/// }
/// ```
///
/// The ``MapStyle/standard(lightPreset:font:showPointOfInterestLabels:showTransitLabels:showPlaceLabels:showRoadLabels:)`` factory method lists the predefined parameters that Standard Style supports. You can also use the Classic Mapbox-designed styles such as ``MapStyle/satelliteStreets``, ``MapStyle/outdoors``, and many more. Or use custom styles that you design with [Mapbox Studio](https://www.mapbox.com/mapbox-studio).
///
///
/// - Important: Configuration can be applied only to `.standard` style or styles that uses `.standard` as import. For any other styles configuration will make no effect.
///
/// ```swift
/// // Use of Mapbox Satellite Streets style.
/// Map().mapStyle(.satelliteStreets)
///
/// // Use of a custom style.
/// Map().mapStyle(MapStyle(uri: StyleURI(rawValue: "CUSTOM_STYLE_URI")!))
/// ```
///
/// - Important: When `MapStyle` is set multiple times only the incremental change of the style will be applied.
///
/// For example, the code below will only load the Standard Style once. The transition to the Dusk light preset will be done animated.
///
/// ```swift
/// mapView.mapboxMap.mapStyle = .standard(stylePreset: .light)
/// // ... some user actions ...
/// mapView.mapboxMap.mapStyle = .standard(stylePreset: .dusk)
/// ```
///
/// The style reloads only when the actual ``StyleURI`` or JSON (when loaded with ``MapStyle/init(json:configuration:)`` is changed. To observe the result of the style load you can subscribe to ``MapboxMap/onStyleLoaded`` or ``Snapshotter/onStyleLoaded`` events, or use use ``StyleManager/load(mapStyle:transition:completion:)`` method.
@_documentation(visibility: public)
@_spi(Experimental)
public struct MapStyle: Equatable {
    enum Data: Equatable {
        case uri(StyleURI)
        case json(String)
    }
    var data: Data
    var configuration: JSONObject?

    /// Creates a map style using a Mapbox Style JSON.
    ///
    /// Please consult [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/) describing the JSON format.
    ///
    /// - Important: For the better performance with large local Style JSON please consider loading style from the file system via the ``MapStyle/init(uri:configuration:)`` initializer.
    ///
    /// - Parameters:
    ///   - json: A Mapbox Style JSON string.
    ///   - configuration: Style import configuration to be applied on style load.
    ///                    Providing `nil` configuration will make no effect and previous configuration will stay in place.  In order to change previous value, you should explicitly override it with the new value.
    @_documentation(visibility: public)
    public init(json: String, configuration: JSONObject? = nil) {
        self.data = .json(json)
        self.configuration = configuration
    }

    /// Creates a map style using a Style URI.
    ///
    /// Use this initializer to make use of pre-defined Mapbox Styles, or load a custom style bundled with the application, or over the network.
    ///
    /// - Parameters:
    ///   - uri: An instance of ``StyleURI`` pointing to a Mapbox Style URI (mapbox://styles/{user}/{style}), a full HTTPS URI, or a path to a local file.
    ///   - configuration: Style import configuration to be applied on style load.
    ///                    Providing `nil` configuration will make no effect and previous configuration will stay in place. In order to change previous value, you should explicitly override it with the new value.
    @_documentation(visibility: public)
    public init(uri: StyleURI, configuration: JSONObject? = nil) {
        self.data = .uri(uri)
        self.configuration = configuration
    }

    /// [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) is a general-purpose style with 3D visualization.
    @_documentation(visibility: public)
    public static var standard: MapStyle { MapStyle(uri: .standard) }

    /// [Mapbox Streets](https://www.mapbox.com/maps/streets) is a general-purpose style with detailed road and transit networks.
    @_documentation(visibility: public)
    public static var streets: MapStyle { MapStyle(uri: .streets) }

    /// [Mapbox Outdoors](https://www.mapbox.com/maps/outdoors) is a general-purpose style tailored to outdoor activities.
    @_documentation(visibility: public)
    public static var outdoors: MapStyle { MapStyle(uri: .outdoors) }

    /// [Mapbox Light](https://www.mapbox.com/maps/light) is a subtle, light-colored backdrop for data visualizations.
    @_documentation(visibility: public)
    public static var light: MapStyle { MapStyle(uri: .light) }

    /// [Mapbox Dark](https://www.mapbox.com/maps/dark) is a subtle, dark-colored backdrop for data visualizations.
    @_documentation(visibility: public)
    public static var dark: MapStyle { MapStyle(uri: .dark) }

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
    @_documentation(visibility: public)
    public static var satellite: MapStyle { MapStyle(uri: .satellite) }

    /// The [Mapbox Satellite Streets](https://www.mapbox.com/maps/satellite) style combines
    /// the high-resolution satellite and aerial imagery of Mapbox Satellite with unobtrusive labels
    /// and translucent roads from Mapbox Streets.
    @_documentation(visibility: public)
    public static var satelliteStreets: MapStyle { MapStyle(uri: .satelliteStreets) }

    /// Empty map style. Allows to load map without any predefined sources or layers.
    /// Allows to construct the whole style in runtime by composition of  `StyleImport`.
    @_documentation(visibility: public)
    public static var empty: MapStyle { MapStyle(json: "{ \"layers\": [], \"sources\": {} }") }

    /// [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) is a general-purpose style with 3D visualization.
    ///
    /// When the returned ``MapStyle`` is set to the map, the Standard Style will be loaded, and specified import configurations will be applied to the basemap.
    ///
    /// - Parameters:
    ///   - lightPreset: Switches between 4 time-of-day states: ``StandardLightPreset/dusk``,  ``StandardLightPreset/dawn``, ``StandardLightPreset/day``, and ``StandardLightPreset/night``.  By default, the Day preset is applied.
    ///   - font: Defines font family for the style from predefined options. The possible options are `Alegreya`, `Alegreya SC`, `Asap`, `Barlow`, `DIN Pro`, `EB Garamond`, `Faustina`, `Frank Ruhl Libre`, `Heebo`, `Inter`, `League Mono`, `Montserrat`, `Poppins`, `Raleway`, `Roboto`, `Roboto Mono`, `Rubik`, `Source`, `Code Pro`, `Spectral`, `Ubuntu`, `Noto Sans CJK JP`, `Open Sans`, `Manrope`, `Source Sans Pro`, `Lato`.
    ///   - showPointOfInterestLabels: Shows or hides all POI icons and text. Default value is `true`.
    ///   - showTransitLabels: Shows or hides all transit icons and text. Default value is `true`.
    ///   - showPlaceLabels: Shows and hides place label layers, such as house numbers. Default value is `true`.
    ///   - showRoadLabels: Shows and hides all road labels, including road shields. Default value is `true`.
    @_documentation(visibility: public)
    public static func standard(
        lightPreset: StandardLightPreset?,
        font: String? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil
    ) -> MapStyle {
        MapStyle(uri: .standard, configuration: standardConfiguration(
              lightPreset: lightPreset,
              font: font,
              showPointOfInterestLabels: showPointOfInterestLabels,
              showTransitLabels: showTransitLabels,
              showPlaceLabels: showPlaceLabels,
              showRoadLabels: showRoadLabels)
        )
    }

    private static func standardConfiguration(
        lightPreset: StandardLightPreset?,
        font: String? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil
    ) -> JSONObject {
        var config = JSONObject()

        if let lightPreset {
            config["lightPreset"] = .string(lightPreset.rawValue)
        }
        if let font {
            config["font"] = .string(font)
        }
        if let showPointOfInterestLabels {
            config["showPointOfInterestLabels"] = .boolean(showPointOfInterestLabels)
        }
        if let showTransitLabels {
            config["showTransitLabels"] = .boolean(showTransitLabels)
        }
        if let showPlaceLabels {
            config["showPlaceLabels"] = .boolean(showPlaceLabels)
        }
        if let showRoadLabels {
            config["showRoadLabels"] = .boolean(showRoadLabels)
        }

        return config
    }
}
