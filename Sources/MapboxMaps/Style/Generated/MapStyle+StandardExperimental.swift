// This file is generated.

extension MapStyle {
    /// NOT FOR PRODUCTION USE. An experimental version of the Mapbox Standard style.
    /// This style is used for testing new features and changes to the Mapbox Standard style. The style may change or be removed at any time.
    ///
    /// - Parameters:
    ///   - theme: Switch between 3 themes: default, faded and monochrome Default value: `default`.
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Defines font family for the style from predefined options. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Shows or hides all POI icons and text. Default value: `true`.
    ///   - showTransitLabels: Shows or hides all transit icons and text. Default value: `true`.
    ///   - showPlaceLabels: Shows and hides place label layers.  Default value: `true`.
    ///   - showRoadLabels: Shows and hides all road labels, including road shields. Default value: `true`.
    ///   - show3dObjects: Shows or hides all 3d layers (3D buildings, landmarks, trees, etc.) including shadows, ambient occlusion, and flood lights. Default value: `true`.
    ///   - buildingHighlightColor: Building color used when setting highlight state. Default value: `hsl(214, 83%, 72%)`.
    ///   - buildingSelectColor: Building color used when setting select state. Default value: `hsl(214, 94%, 59%)`.
    ///   - placeLabelHighlightColor: Place label color used when setting highlight state. Default value: `hsl(4, 43%, 55%)`.
    ///   - placeLabelSelectColor: Place label color used when setting select state. Default value: `hsl(4, 53%, 42%)`.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public static func standardExperimental(
        theme: StandardTheme? = nil,
        lightPreset: StandardLightPreset? = nil,
        font: StandardFont? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil,
        show3dObjects: Bool? = nil,
        buildingHighlightColor: StyleColor? = nil,
        buildingSelectColor: StyleColor? = nil,
        placeLabelHighlightColor: StyleColor? = nil,
        placeLabelSelectColor: StyleColor? = nil
    ) -> MapStyle {
        var config = JSONObject()
        config.encode(key: "theme", value: theme)
        config.encode(key: "lightPreset", value: lightPreset)
        config.encode(key: "font", value: font)
        config.encode(key: "showPointOfInterestLabels", value: showPointOfInterestLabels)
        config.encode(key: "showTransitLabels", value: showTransitLabels)
        config.encode(key: "showPlaceLabels", value: showPlaceLabels)
        config.encode(key: "showRoadLabels", value: showRoadLabels)
        config.encode(key: "show3dObjects", value: show3dObjects)
        config.encode(key: "buildingHighlightColor", value: buildingHighlightColor)
        config.encode(key: "buildingSelectColor", value: buildingSelectColor)
        config.encode(key: "placeLabelHighlightColor", value: placeLabelHighlightColor)
        config.encode(key: "placeLabelSelectColor", value: placeLabelSelectColor)
        return MapStyle(uri: StyleURI(rawValue: "mapbox://styles/mapbox-map-design/standard-experimental-ime")!, configuration: config)
    }

    /// NOT FOR PRODUCTION USE. An experimental version of the Mapbox Standard style.
    /// This style is used for testing new features and changes to the Mapbox Standard style. The style may change or be removed at any time.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public static var standardExperimental: MapStyle { MapStyle(uri: StyleURI(rawValue: "mapbox://styles/mapbox-map-design/standard-experimental-ime")!) }
}
