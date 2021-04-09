import Foundation
import MapboxCoreMaps

extension GlyphsRasterizationOptions {

    /// Convenience initializer
    /// - Parameters:
    ///   - rasterizationMode: Rasterization mode. Defaults to
    ///         `.ideographsRasterizedLocally` i.e. ideographic symbols are
    ///         rasterized locally (not loaded from the server)
    ///   - fontFamilies: Array of fonts, used for glyph rendering.Defaults to
    ///         an appropriate system font.
    ///
    /// - Note:
    ///     If `fontFamilies` is not provided, the SDK will first look for a font
    ///     family (or array of) under the key `MBXIdeographicFontFamilyName`
    ///     in the application's Info.plist. If one is not found, then a system
    ///     font is returned.
    ///
    /// - Note:
    ///     Calling `GlyphsRasterizationOptions()` will currently not call this
    ///     initializer. TODO: mark underlying initializer with NS_UNAVAILABLE

    public convenience init(rasterizationMode: GlyphsRasterizationMode = .ideographsRasterizedLocally,
                            fontFamilies: [String] = []) {
        let resolvedFamilies: [String]
        if fontFamilies.isEmpty {
            resolvedFamilies = Self._defaultFontFamilies()
        } else {
            resolvedFamilies = fontFamilies
        }
        let fontFamilies = resolvedFamilies.joined(separator: "\n")
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
