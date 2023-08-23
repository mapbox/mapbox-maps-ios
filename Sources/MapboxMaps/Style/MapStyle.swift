import MapboxCoreMaps

/// Map style configuration.
///
/// Use MapStyle with ``StyleManager/mapStyle`` or ``Map-swift.struct/mapStyle(_:)`` (SwiftUI)
/// to load a new style, or update style import configurations.
///
/// ```swift
/// // loads Standard Mapbox Style
/// mapboxMap.mapStyle = .standard
///
/// // loads Standard Mapbox Style with Dusk light preset
/// mapboxMap.mapStyle = .standard(lightPreset: .dusk)
///
/// // loads a custom style and updates import configurations for
/// // Mapbox Standard Style imported with "my-import-id" id.
/// mapboxMap.mapStyle = MapStyle(
///     uri: StyleURI(rawValue: "https://example.com/custom-style")!
///     importConfigurations: [
///         .standard(importId: "my-import-id", lightPreset: .dusk)
///     ])
/// ```
///
/// Every new style update is applied incrementally, so it's safe to re-set the style if only one configuration parameter is changed.
///
/// If StyleURI or Style JSON is not equal to the previous value, the update of the ``StyleManager/mapStyle`` will lead to the style reloading.
/// You can observe result of the style reloading in ``MapboxMap/onStyleLoaded`` or ``Snapshotter/onStyleLoaded`` events.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct MapStyle: Equatable {
    enum LoadMethod: Equatable {
        case uri(StyleURI)
        case json(String)
    }
    var loadMethod: LoadMethod
    var importConfigurations: [StyleImportConfiguration]

    /// Creates a map style using a Mapbox Style JSON.
    ///
    /// Please consult [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/) describing the JSON format.
    ///
    /// - Important: For the better performance with large local Style JSON please consider loading style from the file system via the ``MapStyle/init(uri:importConfigurations:)`` initializer.
    ///
    /// - Parameters:
    ///   - json: A Mapbox Style JSON string.
    ///   - importConfigurations: Style import configurations to be applied on style load.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(json: String, importConfigurations: [StyleImportConfiguration] = []) {
        self.loadMethod = .json(json)
        self.importConfigurations = importConfigurations
    }

    /// Creates a map style using StyleURI.
    ///
    /// Use this initializer to make use of pre-defined Mapbox Styles, or load a custom style bundled with the application, or over the network.
    ///
    /// - Parameters:
    ///   - uri: A URI pointing to a Mapbox style URI (mapbox://styles/{user}/{style}), a full HTTPS URI, or a path to a local file.
    ///   - importConfigurations: Style import configurations to be applied on style load.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(uri: StyleURI, importConfigurations: [StyleImportConfiguration] = []) {
        self.loadMethod = .uri(uri)
        self.importConfigurations = importConfigurations
    }

    /// Mapbox Standard is a general-purpose style with 3D visualization.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var standard: MapStyle {
        MapStyle(uri: .standard)
    }

    /// Mapbox Standard is a general-purpose style with 3D visualization.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static func standard(
        lightPreset: StandardLightPreset?,
        font: String? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil
    ) -> MapStyle {
        MapStyle(uri: .standard, importConfigurations: [
            .standard(importId: "basemap", // Import configuration will be applied to the root style.
                      lightPreset: lightPreset,
                      font: font,
                      showPointOfInterestLabels: showPointOfInterestLabels,
                      showTransitLabels: showTransitLabels,
                      showPlaceLabels: showPlaceLabels,
                      showRoadLabels: showRoadLabels)
        ])
    }

    /// Mapbox Streets is a general-purpose style with detailed road and transit networks.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var streets: MapStyle { MapStyle(uri: .streets) }

    /// Mapbox Outdoors is a general-purpose style tailored to outdoor activities.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var outdoors: MapStyle { MapStyle(uri: .outdoors) }

    /// Mapbox Light is a subtle, light-colored backdrop for data visualizations.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var light: MapStyle { MapStyle(uri: .light) }

    /// Mapbox Dark is a subtle, dark-colored backdrop for data visualizations.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var dark: MapStyle { MapStyle(uri: .dark) }

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var satellite: MapStyle { MapStyle(uri: .satellite) }

    /// The Mapbox Satellite Streets style combines the high-resolution satellite and aerial imagery
    /// of Mapbox Satellite with unobtrusive labels and translucent roads from Mapbox Streets.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public static var satelliteStreets: MapStyle { MapStyle(uri: .satelliteStreets) }
}
