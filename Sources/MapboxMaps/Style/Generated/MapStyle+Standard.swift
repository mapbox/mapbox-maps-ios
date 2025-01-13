// This file is generated.

extension MapStyle {
    /// [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) is a general-purpose style with 3D visualization.
    ///
    /// - Parameters:
    ///   - theme: Switch between predefined themes or set a custom theme. Default value: `default`.
    ///   - lightPreset: Switch between 4 time-of-day states: dusk, dawn, day and night. Default value: `day`.
    ///   - font: Defines font family for the style from predefined options. Default value: `DIN Pro`.
    ///   - showPointOfInterestLabels: Shows or hides all POI icons and text. Default value: `true`.
    ///   - showTransitLabels: Shows or hides all transit icons and text. Default value: `true`.
    ///   - showPlaceLabels: Shows and hides place label layers. Default value: `true`.
    ///   - showRoadLabels: Shows and hides all road labels, including road shields. Default value: `true`.
    ///   - showPedestrianRoads: Shows and hides all pedestrian roads, paths, trails. Default value: `true`.
    ///   - show3dObjects: Shows or hides all 3d layers (3D buildings, landmarks, trees, etc.) including shadows, ambient occlusion, and flood lights. Default value: `true`.
    ///   - colorMotorways: Set a custom color for motorway roads. Default value: `hsl(214, 23%, 70%)`.
    ///   - colorPlaceLabelHighlight: Place label color used when setting highlight state. Default value: `hsl(4, 43%, 55%)`.
    ///   - colorPlaceLabelSelect: Place label color used when setting select state. Default value: `hsl(4, 53%, 42%)`.
    ///   - colorRoads: Set a custom color for other roads. Default value: `hsl(224, 25%, 80%)`.
    ///   - colorTrunks: Set a custom color for trunk roads. Default value: `hsl(235, 20%, 70%)`.
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
        colorMotorways: StyleColor? = nil,
        colorPlaceLabelHighlight: StyleColor? = nil,
        colorPlaceLabelSelect: StyleColor? = nil,
        colorRoads: StyleColor? = nil,
        colorTrunks: StyleColor? = nil,
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
        config.encode(key: "colorMotorways", value: colorMotorways)
        config.encode(key: "colorPlaceLabelHighlight", value: colorPlaceLabelHighlight)
        config.encode(key: "colorPlaceLabelSelect", value: colorPlaceLabelSelect)
        config.encode(key: "colorRoads", value: colorRoads)
        config.encode(key: "colorTrunks", value: colorTrunks)
        config.encode(key: "theme-data", value: themeData)
        return MapStyle(uri: .standard, configuration: config)
    }

    /// [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) is a general-purpose style with 3D visualization.
    public static var standard: MapStyle { MapStyle(uri: .standard) }
}

extension StyleURI {
    /// [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) is a general-purpose style with 3D visualization.
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

/// Defines font family for the style from predefined options.
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
