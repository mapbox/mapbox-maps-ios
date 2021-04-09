import Foundation
import MapboxCoreMaps

extension GlyphsRasterizationOptions {

    /// Default GlyphsRasterizationOptions. RasterizationMode defaults to
    /// `.ideographsRasterizedLocally` i.e. ideographic symbols are rasterized locally (not loaded
    /// from the server) using an appropriate system font.
    public static let `default`: GlyphsRasterizationOptions =
        GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally)

    /// Convenience initializer
    /// - Parameters:
    ///   - rasterizationMode: Rasterization mode
    ///   - fontFamilies: Array of fonts, used for glyph rendering.Defaults to
    ///                   an appropriate system font.
    ///
    /// - Note:
    ///     If `fontFamilies` is not provided, the SDK wil first look for a font
    ///     family (or array of) under the key `MBXIdeographicFontFamilyName`
    ///     in the application's Info.plist. If one is not found, then a system
    ///     font is returned.
    public convenience init(rasterizationMode: GlyphsRasterizationMode,
                            fontFamilies: [String] = _defaultFontFamilies()) {
        let fontFamilies = fontFamilies.joined(separator: "\n")
        self.init(rasterizationMode: rasterizationMode, fontFamily: fontFamilies)
    }

    /// Return the default font family/families
    public static func _defaultFontFamilies() -> [String] {
        switch Bundle.main.infoDictionary?["MBXIdeographicFontFamilyName"] {
        case let family as String:
            return [family]
        case let families as [String]:
            return families
        default:
            return [fallbackFontFamilyName]
        }
    }

    internal static let fallbackFontFamilyName =
        UIFont.systemFont(ofSize: 0, weight: .regular).familyName
}
