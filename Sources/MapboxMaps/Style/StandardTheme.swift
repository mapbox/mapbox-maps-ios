/// Defines the available themes in the Mapbox Standard Style.
public struct StandardTheme: RawRepresentable, Hashable {
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
}
