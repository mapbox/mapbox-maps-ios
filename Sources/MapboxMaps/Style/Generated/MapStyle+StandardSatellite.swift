// This file is generated.

extension MapStyle {
    /// Mapbox Standard Satellite style.
    ///
    /// - Parameters:
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Defines font family for the style from predefined options. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Shows or hides all POI icons and text. Default value: `true`.
    ///   - showTransitLabels: Shows or hides all transit icons and text. Default value: `true`.
    ///   - showPlaceLabels: Shows and hides place label layers.  Default value: `true`.
    ///   - showRoadLabels: Shows and hides all road labels, including road shields. Default value: `true`.
    ///   - showRoadsAndTransit: Shows and hides all roads and transit networks  Default value: `true`.
    ///   - showPedestrianRoads: Shows and hides all pedestrian roads, paths, trails
    public static func standardSatellite(
        lightPreset: StandardLightPreset? = nil,
        font: StandardFont? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil,
        showRoadsAndTransit: Bool? = nil,
        showPedestrianRoads: Bool? = nil
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
        return MapStyle(uri: .standardSatellite, configuration: config)
    }

    /// Mapbox Standard Satellite style.
    public static var standardSatellite: MapStyle { MapStyle(uri: .standardSatellite) }
}

extension StyleURI {
    /// Mapbox Standard Satellite style.
    public static var standardSatellite: StyleURI { StyleURI(rawValue: "mapbox://styles/mapbox/standard-satellite")! }
}
