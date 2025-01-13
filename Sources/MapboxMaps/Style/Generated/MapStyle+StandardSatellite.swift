// This file is generated.

extension MapStyle {
    /// Mapbox Standard Satellite style.
    ///
    /// - Parameters:
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Defines font family for the style from predefined options. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Shows or hides all POI icons and text. Default value: `true`.
    ///   - showTransitLabels: Shows or hides all transit icons and text. Default value: `true`.
    ///   - showPlaceLabels: Shows and hides place label layers. Default value: `true`.
    ///   - showRoadLabels: Shows and hides all road labels, including road shields. Default value: `true`.
    ///   - showRoadsAndTransit: Shows and hides all roads and transit networks. Default value: `true`.
    ///   - showPedestrianRoads: Shows and hides all pedestrian roads, paths, trails.
    ///   - colorMotorways: Set a custom color for motorway roads. Default value: `hsl(214, 23%, 80%)`.
    ///   - colorPlaceLabelHighlight: Place label color used when setting highlight state. Default value: `hsl(5, 80%, 75%)`.
    ///   - colorPlaceLabelSelect: Place label color used when setting select state. Default value: `hsl(5, 95%, 70%)`.
    ///   - colorRoads: Set a custom color for roads. Default value: `hsl(224, 25%, 75%)`.
    ///   - colorTrunks: Set a custom color for trunk roads. Default value: `hsl(235, 20%, 80%)`.
    public static func standardSatellite(
        lightPreset: StandardLightPreset? = nil,
        font: StandardFont? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil,
        showRoadsAndTransit: Bool? = nil,
        showPedestrianRoads: Bool? = nil,
        colorMotorways: StyleColor? = nil,
        colorPlaceLabelHighlight: StyleColor? = nil,
        colorPlaceLabelSelect: StyleColor? = nil,
        colorRoads: StyleColor? = nil,
        colorTrunks: StyleColor? = nil
    ) -> MapStyle {
        var config = JSONObject()
        config.encode(key: "lightPreset", value: lightPreset)
        config.encode(key: "font", value: font)
        config.encode(key: "showPointOfInterestLabels", value: showPointOfInterestLabels)
        config.encode(key: "showTransitLabels", value: showTransitLabels)
        config.encode(key: "showPlaceLabels", value: showPlaceLabels)
        config.encode(key: "showRoadLabels", value: showRoadLabels)
        config.encode(key: "showRoadsAndTransit", value: showRoadsAndTransit)
        config.encode(key: "showPedestrianRoads", value: showPedestrianRoads)
        config.encode(key: "colorMotorways", value: colorMotorways)
        config.encode(key: "colorPlaceLabelHighlight", value: colorPlaceLabelHighlight)
        config.encode(key: "colorPlaceLabelSelect", value: colorPlaceLabelSelect)
        config.encode(key: "colorRoads", value: colorRoads)
        config.encode(key: "colorTrunks", value: colorTrunks)
        return MapStyle(uri: .standardSatellite, configuration: config)
    }

    /// Mapbox Standard Satellite style.
    public static var standardSatellite: MapStyle { MapStyle(uri: .standardSatellite) }
}

extension StyleURI {
    /// Mapbox Standard Satellite style.
    public static var standardSatellite: StyleURI { StyleURI(rawValue: "mapbox://styles/mapbox/standard-satellite")! }
}
