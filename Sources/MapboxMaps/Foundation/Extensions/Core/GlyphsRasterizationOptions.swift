import Foundation
import MapboxCoreMaps

extension GlyphsRasterizationOptions {

    /// Default fallback font
    internal static var fallbackFontFamilyName: String = {
        UIFont.systemFont(ofSize: 0, weight: .regular).familyName
    }()

    /// Default GlyphsRasterizationOptions. RasterizationMode defaults to
    /// `.ideographsRasterizedLocally` i.e. ideographic symbols are rasterized locally (not loaded
    /// from the server) using an appropriate system font.
    public static var `default`: GlyphsRasterizationOptions = {
        GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally)
    }()

    /// Convenience initializer
    /// - Parameters:
    ///   - rasterizationMode: Rasterization mode
    ///   - fontFamilies: Array of fonts, used for glyph rendering. Defaults to an appropriate
    ///   system font
    public convenience init(rasterizationMode: GlyphsRasterizationMode,
                            fontFamilies: [String] = []) {
        let fontFamilies = fontFamilies.isEmpty ? Self.fallbackFontFamilyName : fontFamilies.joined(separator: "\n")
        self.init(rasterizationMode: rasterizationMode, fontFamily: fontFamilies)
    }
}
