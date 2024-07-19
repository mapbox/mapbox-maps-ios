/// Defines the available light presets in the Mapbox Standard Style.
public struct StandardLightPreset: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Day light preset.
    public static let day = StandardLightPreset(rawValue: "day")

    /// Night light preset.
    public static let night = StandardLightPreset(rawValue: "night")

    /// Dusk light preset.
    public static let dusk = StandardLightPreset(rawValue: "dusk")

    /// Dawn light preset.
    public static let dawn = StandardLightPreset(rawValue: "dawn")
}
