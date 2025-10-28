// This file is generated.

extension MapStyle {
    /// Mapbox Standard Satellite style.
    ///
    /// - Parameters:
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Set the text font family. The basemap uses Medium, Bold, Italic and Regular. Falls back to Arial Unicode MS if a weight is missing. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Show or hide POI labels. Default value: `true`.
    ///   - showTransitLabels: Show or hide transit labels. Default value: `true`.
    ///   - showPlaceLabels: Show or hide place label layers. Default value: `true`.
    ///   - showRoadLabels: Show or hide road labels including road shields. Default value: `true`.
    ///   - showRoadsAndTransit: Show or hide roads and transit networks. Default value: `true`.
    ///   - showPedestrianRoads: Show or hide pedestrian roads, paths, and trails.
    ///   - backgroundPointOfInterestLabels: Set background shape for POI labels. Default value: `circle`.
    ///   - colorAdminBoundaries: Set a custom color for administrative boundaries. Default value: `hsl(345, 100%, 70%)`.
    ///   - colorModePointOfInterestLabels: Use the default categorical colors or set a single custom color for POI labels. Default value: `default`.
    ///   - colorMotorways: Set a custom color for motorway roads. Default value: `hsl(214, 23%, 80%)`.
    ///   - colorPlaceLabelHighlight: Place label color used when setting highlight state. Default value: `hsl(5, 80%, 75%)`.
    ///   - colorPlaceLabels: Set a custom color for place labels. Default value: `hsl(0, 0%, 100%)`.
    ///   - colorPlaceLabelSelect: Place label color used when setting select state. Default value: `hsl(5, 95%, 70%)`.
    ///   - colorPointOfInterestLabels: Set a custom color for POI labels. Default value: `#848e94`.
    ///   - colorRoadLabels: Set a custom color for road labels. Default value: `hsl(0, 0%, 100%)`.
    ///   - colorRoads: Set a custom color for roads. Default value: `hsl(224, 25%, 75%)`.
    ///   - colorTrunks: Set a custom color for trunk roads. Default value: `hsl(235, 20%, 80%)`.
    ///   - densityPointOfInterestLabels: Set the density of POI labels. Default value: `3`.
    ///   - fuelingStationModePointOfInterestLabels: Control the visibility of fuel and electric charging station POI labels. Default displays both types. Default value: `default`.
    ///   - roadsBrightness: Control how bright road network appear in dark styles. Default value: `0.7`.
    ///   - showAdminBoundaries: Show or hide administrative boundaries. Default value: `true`.
    public static func standardSatellite(
        lightPreset: StandardLightPreset? = nil,
        font: StandardFont? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil,
        showRoadsAndTransit: Bool? = nil,
        showPedestrianRoads: Bool? = nil,
        backgroundPointOfInterestLabels: StandardBackgroundPointOfInterestLabels? = nil,
        colorAdminBoundaries: StyleColor? = nil,
        colorModePointOfInterestLabels: StandardColorModePointOfInterestLabels? = nil,
        colorMotorways: StyleColor? = nil,
        colorPlaceLabelHighlight: StyleColor? = nil,
        colorPlaceLabels: StyleColor? = nil,
        colorPlaceLabelSelect: StyleColor? = nil,
        colorPointOfInterestLabels: StyleColor? = nil,
        colorRoadLabels: StyleColor? = nil,
        colorRoads: StyleColor? = nil,
        colorTrunks: StyleColor? = nil,
        densityPointOfInterestLabels: Double? = nil,
        fuelingStationModePointOfInterestLabels: StandardFuelingStationModePointOfInterestLabels? = nil,
        roadsBrightness: Double? = nil,
        showAdminBoundaries: Bool? = nil
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
        config.encode(key: "backgroundPointOfInterestLabels", value: backgroundPointOfInterestLabels)
        config.encode(key: "colorAdminBoundaries", value: colorAdminBoundaries)
        config.encode(key: "colorModePointOfInterestLabels", value: colorModePointOfInterestLabels)
        config.encode(key: "colorMotorways", value: colorMotorways)
        config.encode(key: "colorPlaceLabelHighlight", value: colorPlaceLabelHighlight)
        config.encode(key: "colorPlaceLabels", value: colorPlaceLabels)
        config.encode(key: "colorPlaceLabelSelect", value: colorPlaceLabelSelect)
        config.encode(key: "colorPointOfInterestLabels", value: colorPointOfInterestLabels)
        config.encode(key: "colorRoadLabels", value: colorRoadLabels)
        config.encode(key: "colorRoads", value: colorRoads)
        config.encode(key: "colorTrunks", value: colorTrunks)
        config.encode(key: "densityPointOfInterestLabels", value: densityPointOfInterestLabels)
        config.encode(key: "fuelingStationModePointOfInterestLabels", value: fuelingStationModePointOfInterestLabels)
        config.encode(key: "roadsBrightness", value: roadsBrightness)
        config.encode(key: "showAdminBoundaries", value: showAdminBoundaries)
        return MapStyle(uri: .standardSatellite, configuration: config)
    }

    /// Mapbox Standard Satellite style.
    public static var standardSatellite: MapStyle { MapStyle(uri: .standardSatellite) }
}

extension StyleURI {
    /// Mapbox Standard Satellite style.
    public static var standardSatellite: StyleURI { StyleURI(rawValue: "mapbox://styles/mapbox/standard-satellite")! }
}
