// This file is generated.

extension MapStyle {
    /// [Mapbox Standard](https://docs.mapbox.com/map-styles/standard/guides/) is a general-purpose style with 3D visualization.
    ///
    /// - Parameters:
    ///   - theme: Switch between predefined themes or set a custom theme. Default value: `default`.
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Set the text font family. The basemap uses Medium, Bold, Italic and Regular. Falls back to Arial Unicode MS if a weight is missing. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Show or hide POI labels. Default value: `true`.
    ///   - showTransitLabels: Show or hide transit labels. Default value: `true`.
    ///   - showPlaceLabels: Show or hide place labels. Default value: `true`.
    ///   - showRoadLabels: Show or hide road labels including road shields. Default value: `true`.
    ///   - showPedestrianRoads: Show or hide pedestrian roads, paths, and trails. Default value: `true`.
    ///   - show3dObjects: Show or hide all 3D objects, including buildings, landmarks, and trees. Default value: `true`.
    ///   - backgroundPointOfInterestLabels: Set background shape for POI labels. Default value: `circle`.
    ///   - colorAdminBoundaries: Set a custom color for administrative boundaries. Default value: `hsl(345, 100%, 70%)`.
    ///   - colorBuildingHighlight: Set a custom color for building fill extrusion when setting highlight state. Default value: `hsl(34, 30%, 93%)`.
    ///   - colorBuildings: Set a custom color for 3D & 2D buildings. Default value: `hsl(40, 43%, 93%)`.
    ///   - colorBuildingSelect: Set a custom color for building fill extrusion when setting select state. Default value: `hsl(214, 82%, 63%)`.
    ///   - colorCommercial: Set a custom color for commercial areas. Default value: `hsla(24, 100%, 94%, 1)`.
    ///   - colorEducation: Set a custom color for education areas. Default value: `hsl(40, 50%, 88%)`.
    ///   - colorGreenspace: Set a custom color for greenspaces such as forests, parks, and woods. Default value: `hsl(115, 60%, 84%)`.
    ///   - colorIndustrial: Set a custom color for industrial areas and airports. Default value: `hsl(230, 15%, 92%)`.
    ///   - colorLand: Set a custom color for land. Default value: `hsl(20, 20%, 95%)`.
    ///   - colorMedical: Set a custom color for medical areas. Default value: `hsl(0, 50%, 92%)`.
    ///   - colorModePointOfInterestLabels: Use the default categorical colors or set a single custom color for POI labels. Default value: `default`.
    ///   - colorMotorways: Set a custom color for motorway roads. Default value: `hsl(214, 23%, 70%)`.
    ///   - colorPlaceLabelHighlight: Set a custom color for place labels when setting highlight state. Default value: `hsl(4, 43%, 55%)`.
    ///   - colorPlaceLabels: Set a custom color for place labels. Default value: `hsl(0, 0%, 0%)`.
    ///   - colorPlaceLabelSelect: Set a custom color for place labels when setting select state. Default value: `hsl(4, 53%, 42%)`.
    ///   - colorPointOfInterestLabels: Set a custom color for POI labels. Default value: `#848e94`.
    ///   - colorRoadLabels: Set a custom color for road labels. Default value: `hsl(0, 0%, 25%)`.
    ///   - colorRoads: Set a custom color for other roads. Default value: `hsl(224, 25%, 80%)`.
    ///   - colorTrunks: Set a custom color for trunk roads. Default value: `hsl(235, 20%, 70%)`.
    ///   - colorWater: Set a custom color for water. Default value: `hsl(200, 100%, 80%)`.
    ///   - densityPointOfInterestLabels: Set the density of POI labels. Default value: `3`.
    ///   - fuelingStationModePointOfInterestLabels: Control the visibility of fuel and electric charging station POI labels. Default displays both types. Default value: `default`.
    ///   - roadsBrightness: Control how bright roads appear in dark styles. Default value: `0.4`.
    ///   - show3dBuildings: Show or hide 3D buildings. Default value: `true`.
    ///   - show3dFacades: Show or hide 3D building facades.
    ///   - show3dLandmarks: Show or hide 3D landmark buildings. Default value: `true`.
    ///   - show3dTrees: Show or hide 3D trees. Default value: `true`.
    ///   - showAdminBoundaries: Show or hide administrative boundaries. Default value: `true`.
    ///   - showLandmarkIconLabels: Show or hide Landmark icon labels. Default value: `true`.
    ///   - showLandmarkIcons: Show or hide Landmark icons.
    ///   - themeData: Set a custom theme based on a look-up table (LUT).
    public static func standard(
        theme: StandardTheme? = nil,
        lightPreset: StandardLightPreset? = nil,
        font: StandardFont? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil,
        showPedestrianRoads: Bool? = nil,
        show3dObjects: Bool? = nil,
        backgroundPointOfInterestLabels: StandardBackgroundPointOfInterestLabels? = nil,
        colorAdminBoundaries: StyleColor? = nil,
        colorBuildingHighlight: StyleColor? = nil,
        colorBuildings: StyleColor? = nil,
        colorBuildingSelect: StyleColor? = nil,
        colorCommercial: StyleColor? = nil,
        colorEducation: StyleColor? = nil,
        colorGreenspace: StyleColor? = nil,
        colorIndustrial: StyleColor? = nil,
        colorLand: StyleColor? = nil,
        colorMedical: StyleColor? = nil,
        colorModePointOfInterestLabels: StandardColorModePointOfInterestLabels? = nil,
        colorMotorways: StyleColor? = nil,
        colorPlaceLabelHighlight: StyleColor? = nil,
        colorPlaceLabels: StyleColor? = nil,
        colorPlaceLabelSelect: StyleColor? = nil,
        colorPointOfInterestLabels: StyleColor? = nil,
        colorRoadLabels: StyleColor? = nil,
        colorRoads: StyleColor? = nil,
        colorTrunks: StyleColor? = nil,
        colorWater: StyleColor? = nil,
        densityPointOfInterestLabels: Double? = nil,
        fuelingStationModePointOfInterestLabels: StandardFuelingStationModePointOfInterestLabels? = nil,
        roadsBrightness: Double? = nil,
        show3dBuildings: Bool? = nil,
        show3dFacades: Bool? = nil,
        show3dLandmarks: Bool? = nil,
        show3dTrees: Bool? = nil,
        showAdminBoundaries: Bool? = nil,
        showLandmarkIconLabels: Bool? = nil,
        showLandmarkIcons: Bool? = nil,
        themeData: String? = nil
    ) -> MapStyle {
        var config = JSONObject()
        config.encode(key: "theme", value: theme)
        config.encode(key: "lightPreset", value: lightPreset)
        config.encode(key: "font", value: font)
        config.encode(key: "showPointOfInterestLabels", value: showPointOfInterestLabels)
        config.encode(key: "showTransitLabels", value: showTransitLabels)
        config.encode(key: "showPlaceLabels", value: showPlaceLabels)
        config.encode(key: "showRoadLabels", value: showRoadLabels)
        config.encode(key: "showPedestrianRoads", value: showPedestrianRoads)
        config.encode(key: "show3dObjects", value: show3dObjects)
        config.encode(key: "backgroundPointOfInterestLabels", value: backgroundPointOfInterestLabels)
        config.encode(key: "colorAdminBoundaries", value: colorAdminBoundaries)
        config.encode(key: "colorBuildingHighlight", value: colorBuildingHighlight)
        config.encode(key: "colorBuildings", value: colorBuildings)
        config.encode(key: "colorBuildingSelect", value: colorBuildingSelect)
        config.encode(key: "colorCommercial", value: colorCommercial)
        config.encode(key: "colorEducation", value: colorEducation)
        config.encode(key: "colorGreenspace", value: colorGreenspace)
        config.encode(key: "colorIndustrial", value: colorIndustrial)
        config.encode(key: "colorLand", value: colorLand)
        config.encode(key: "colorMedical", value: colorMedical)
        config.encode(key: "colorModePointOfInterestLabels", value: colorModePointOfInterestLabels)
        config.encode(key: "colorMotorways", value: colorMotorways)
        config.encode(key: "colorPlaceLabelHighlight", value: colorPlaceLabelHighlight)
        config.encode(key: "colorPlaceLabels", value: colorPlaceLabels)
        config.encode(key: "colorPlaceLabelSelect", value: colorPlaceLabelSelect)
        config.encode(key: "colorPointOfInterestLabels", value: colorPointOfInterestLabels)
        config.encode(key: "colorRoadLabels", value: colorRoadLabels)
        config.encode(key: "colorRoads", value: colorRoads)
        config.encode(key: "colorTrunks", value: colorTrunks)
        config.encode(key: "colorWater", value: colorWater)
        config.encode(key: "densityPointOfInterestLabels", value: densityPointOfInterestLabels)
        config.encode(key: "fuelingStationModePointOfInterestLabels", value: fuelingStationModePointOfInterestLabels)
        config.encode(key: "roadsBrightness", value: roadsBrightness)
        config.encode(key: "show3dBuildings", value: show3dBuildings)
        config.encode(key: "show3dFacades", value: show3dFacades)
        config.encode(key: "show3dLandmarks", value: show3dLandmarks)
        config.encode(key: "show3dTrees", value: show3dTrees)
        config.encode(key: "showAdminBoundaries", value: showAdminBoundaries)
        config.encode(key: "showLandmarkIconLabels", value: showLandmarkIconLabels)
        config.encode(key: "showLandmarkIcons", value: showLandmarkIcons)
        config.encode(key: "theme-data", value: themeData)
        return MapStyle(uri: .standard, configuration: config)
    }

    /// [Mapbox Standard](https://docs.mapbox.com/map-styles/standard/guides/) is a general-purpose style with 3D visualization.
    public static var standard: MapStyle { MapStyle(uri: .standard) }
}

extension StyleURI {
    /// [Mapbox Standard](https://docs.mapbox.com/map-styles/standard/guides/) is a general-purpose style with 3D visualization.
    public static var standard: StyleURI { StyleURI(rawValue: "mapbox://styles/mapbox/standard")! }
}

/// Switch between predefined themes or set a custom theme.
public struct StandardTheme: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Default theme.
    public static let `default` = StandardTheme(rawValue: "default")

    /// Faded theme.
    public static let faded = StandardTheme(rawValue: "faded")

    /// Monochrome theme.
    public static let monochrome = StandardTheme(rawValue: "monochrome")

    /// Custom theme.
    public static let custom = StandardTheme(rawValue: "custom")
}

/// Switch between 4 time-of-day states: dusk, dawn, day and night.
public struct StandardLightPreset: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Dawn light preset.
    public static let dawn = StandardLightPreset(rawValue: "dawn")

    /// Day light preset.
    public static let day = StandardLightPreset(rawValue: "day")

    /// Dusk light preset.
    public static let dusk = StandardLightPreset(rawValue: "dusk")

    /// Night light preset.
    public static let night = StandardLightPreset(rawValue: "night")
}

/// Set the text font family. The basemap uses Medium, Bold, Italic and Regular. Falls back to Arial Unicode MS if a weight is missing.
public struct StandardFont: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Alegreya font.
    public static let alegreya = StandardFont(rawValue: "Alegreya")

    /// Alegreya SC font.
    public static let alegreyaSc = StandardFont(rawValue: "Alegreya SC")

    /// Asap font.
    public static let asap = StandardFont(rawValue: "Asap")

    /// Barlow font.
    public static let barlow = StandardFont(rawValue: "Barlow")

    /// DIN Pro font.
    public static let dinPro = StandardFont(rawValue: "DIN Pro")

    /// EB Garamond font.
    public static let ebGaramond = StandardFont(rawValue: "EB Garamond")

    /// Faustina font.
    public static let faustina = StandardFont(rawValue: "Faustina")

    /// Frank Ruhl Libre font.
    public static let frankRuhlLibre = StandardFont(rawValue: "Frank Ruhl Libre")

    /// Heebo font.
    public static let heebo = StandardFont(rawValue: "Heebo")

    /// Inter font.
    public static let inter = StandardFont(rawValue: "Inter")

    /// Lato font.
    public static let lato = StandardFont(rawValue: "Lato")

    /// League Mono font.
    public static let leagueMono = StandardFont(rawValue: "League Mono")

    /// Montserrat font.
    public static let montserrat = StandardFont(rawValue: "Montserrat")

    /// Manrope font.
    public static let manrope = StandardFont(rawValue: "Manrope")

    /// Noto Sans CJK JP font.
    public static let notoSansCjkJp = StandardFont(rawValue: "Noto Sans CJK JP")

    /// Open Sans font.
    public static let openSans = StandardFont(rawValue: "Open Sans")

    /// Poppins font.
    public static let poppins = StandardFont(rawValue: "Poppins")

    /// Raleway font.
    public static let raleway = StandardFont(rawValue: "Raleway")

    /// Roboto font.
    public static let roboto = StandardFont(rawValue: "Roboto")

    /// Roboto Mono font.
    public static let robotoMono = StandardFont(rawValue: "Roboto Mono")

    /// Rubik font.
    public static let rubik = StandardFont(rawValue: "Rubik")

    /// Source Code Pro font.
    public static let sourceCodePro = StandardFont(rawValue: "Source Code Pro")

    /// Source Sans Pro font.
    public static let sourceSansPro = StandardFont(rawValue: "Source Sans Pro")

    /// Spectral font.
    public static let spectral = StandardFont(rawValue: "Spectral")

    /// Ubuntu font.
    public static let ubuntu = StandardFont(rawValue: "Ubuntu")
}

/// Set background shape for POI labels.
public struct StandardBackgroundPointOfInterestLabels: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Circle background point of interest labels.
    public static let circle = StandardBackgroundPointOfInterestLabels(rawValue: "circle")

    /// None background point of interest labels.
    public static let noBackground = StandardBackgroundPointOfInterestLabels(rawValue: "none")
}

/// Use the default categorical colors or set a single custom color for POI labels.
public struct StandardColorModePointOfInterestLabels: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Default color mode point of interest labels.
    public static let `default` = StandardColorModePointOfInterestLabels(rawValue: "default")

    /// Single color mode point of interest labels.
    public static let single = StandardColorModePointOfInterestLabels(rawValue: "single")
}

/// Control the visibility of fuel and electric charging station POI labels. Default displays both types.
public struct StandardFuelingStationModePointOfInterestLabels: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Default fueling station mode point of interest labels.
    public static let `default` = StandardFuelingStationModePointOfInterestLabels(rawValue: "default")

    /// Fuel fueling station mode point of interest labels.
    public static let fuel = StandardFuelingStationModePointOfInterestLabels(rawValue: "fuel")

    /// Electric fueling station mode point of interest labels.
    public static let electric = StandardFuelingStationModePointOfInterestLabels(rawValue: "electric")

    /// None fueling station mode point of interest labels.
    public static let none = StandardFuelingStationModePointOfInterestLabels(rawValue: "none")
}
