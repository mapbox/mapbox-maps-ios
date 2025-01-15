import MapboxCoreMaps

/// Map style configuration.
///
/// Set map style to style manager's ``StyleManager/mapStyle`` property to load a new style, or update style import configurations when you work with ``MapView``:
///
/// ```swift
/// let mapView = MapView()
///
/// // Loads the Mapbox Standard Style.
/// mapView.mapboxMap.mapStyle = .standard
///
/// // Loads the Mapbox Standard Style with Dusk light preset.
/// mapView.mapboxMap.mapStyle = .standard(lightPreset: .dusk)
///
/// // Loads a custom style.
/// mapView.mapboxMap.mapStyle = MapStyle(
///     uri: StyleURI(rawValue: "https://example.com/custom-style")!,
///     configuration: [
///         "key": "value" // optional import configuration
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
/// The ``MapStyle/standard(theme:lightPreset:font:showPointOfInterestLabels:showTransitLabels:showPlaceLabels:showRoadLabels:showPedestrianRoads:show3dObjects:colorMotorways:colorPlaceLabelHighlight:colorPlaceLabelSelect:colorRoads:colorTrunks:themeData:)`` factory method lists the predefined parameters that Standard Style supports. You can also use the Classic Mapbox-designed styles such as ``MapStyle/satelliteStreets``, ``MapStyle/outdoors``, and many more. Or use custom styles that you design with [Mapbox Studio](https://www.mapbox.com/mapbox-studio).
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
public struct MapStyle: Equatable, Sendable {
    enum Data: Equatable, Sendable {
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
    public init(uri: StyleURI, configuration: JSONObject? = nil) {
        self.data = .uri(uri)
        self.configuration = configuration
    }

    /// [Mapbox Streets](https://www.mapbox.com/maps/streets) is a general-purpose style with detailed road and transit networks.
    public static var streets: MapStyle { MapStyle(uri: .streets) }

    /// [Mapbox Outdoors](https://www.mapbox.com/maps/outdoors) is a general-purpose style tailored to outdoor activities.
    public static var outdoors: MapStyle { MapStyle(uri: .outdoors) }

    /// [Mapbox Light](https://www.mapbox.com/maps/light) is a subtle, light-colored backdrop for data visualizations.
    public static var light: MapStyle { MapStyle(uri: .light) }

    /// [Mapbox Dark](https://www.mapbox.com/maps/dark) is a subtle, dark-colored backdrop for data visualizations.
    public static var dark: MapStyle { MapStyle(uri: .dark) }

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
    public static var satellite: MapStyle { MapStyle(uri: .satellite) }

    /// The [Mapbox Satellite Streets](https://www.mapbox.com/maps/satellite) style combines
    /// the high-resolution satellite and aerial imagery of Mapbox Satellite with unobtrusive labels
    /// and translucent roads from Mapbox Streets.
    public static var satelliteStreets: MapStyle { MapStyle(uri: .satelliteStreets) }

    /// Empty map style. Allows to load map without any predefined sources or layers.
    /// Allows to construct the whole style in runtime by composition of  `StyleImport`.
    public static var empty: MapStyle { MapStyle(json: "{ \"layers\": [], \"sources\": {} }") }
}

/// Source compatibility with raw strings for Standard Font.
extension StandardFont: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
