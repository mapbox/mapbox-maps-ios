import Foundation
import MapboxCoreMaps


public extension GlyphsRasterizationOptions {

    /// Default fallback font
    static var fallbackFontFamilyName: String = {
        UIFont.systemFont(ofSize: 0, weight: .regular).familyName
    }()

    /// Default GlyphsRasterizationOptions. RasterizationMode defaults to
    /// `.ideographsRasterizedLocally` i.e. ideographic symbols are rasterized locally (not loaded
    /// from the server) using an appropriate system font.
    static var `default`: GlyphsRasterizationOptions = {
        GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally)
    }()

    /// Convenience initializer
    /// - Parameters:
    ///   - rasterizationMode: Rasterization mode
    ///   - fontFamilies: Array of fonts, used for glyph rendering. Defaults to an appropriate
    ///   system font
    convenience init(rasterizationMode: GlyphsRasterizationMode,
                     fontFamilies: [String] = []) {
        let fontFamilies = fontFamilies.isEmpty ? Self.fallbackFontFamilyName : fontFamilies.joined(separator: "\n")
        self.init(rasterizationMode: rasterizationMode, fontFamily: fontFamilies)
    }
}
