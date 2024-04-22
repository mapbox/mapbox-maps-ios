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
