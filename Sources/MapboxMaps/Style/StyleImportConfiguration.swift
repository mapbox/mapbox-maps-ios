/// Defines the available light presets in the Mapbox Standard Style.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct StandardLightPreset: RawRepresentable, Hashable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Day light preset.
    @_documentation(visibility: public)
    public static let day = StandardLightPreset(rawValue: "day")

    /// Night light preset.
    @_documentation(visibility: public)
    public static let night = StandardLightPreset(rawValue: "night")

    /// Dusk light preset.
    @_documentation(visibility: public)
    public static let dusk = StandardLightPreset(rawValue: "dusk")

    /// Dawn light preset.
    @_documentation(visibility: public)
    public static let dawn = StandardLightPreset(rawValue: "dawn")
}

/// Specifies configuration parameters for style imports.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct StyleImportConfiguration: Equatable {
    /// Style import identifier.
    @_documentation(visibility: public)
    public var importId: String

    /// JSON dictionary of parameters.
    @_documentation(visibility: public)
    public var config: JSONObject

    /// Creates a configuration.
    /// - Parameters:
    ///   - importId: A style import id to which the configuration will be applied. If not specified, the import configuration will be applied to `basemap` style import (root style).
    ///   - config: Style import configuration parameters.
    @_documentation(visibility: public)
    public init(importId: String?, config: JSONObject) {
        self.importId = importId ?? "basemap"
        self.config = config
    }

    /// Creates a configuration for the Mapbox Standard Style.
    @_documentation(visibility: public)
    public static func standard(
        importId: String?,
        lightPreset: StandardLightPreset? = nil,
        font: String? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil
    ) -> StyleImportConfiguration {
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

        return StyleImportConfiguration(importId: importId, config: config)
    }
}
