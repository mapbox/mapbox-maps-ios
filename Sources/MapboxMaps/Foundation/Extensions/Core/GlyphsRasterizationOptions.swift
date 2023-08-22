import UIKit
import MapboxCoreMaps

extension GlyphsRasterizationOptions {

    /// Convenience initializer
    /// - Parameters:
    ///   - rasterizationMode: Rasterization mode. Defaults to
    ///         `.ideographsRasterizedLocally` i.e. ideographic symbols are
    ///         rasterized locally (not loaded from the server)
    ///   - fontFamilies: Array of fonts, used for glyph rendering. Defaults to
    ///         an appropriate system font. This parameter is ignored if
    ///         `rasterizationMode` is `.noGlyphsRasterizedLocally`
    ///
    /// - Note:
    ///     If `fontFamilies` is not provided, the SDK will first look for a font
    ///     family (or array of) under the key `MBXIdeographicFontFamilyName`
    ///     in the application's Info.plist. If one is not found, then a system
    ///     font is returned.
    ///
    /// - Note:
    ///     Calling `GlyphsRasterizationOptions()` will currently not call this
    ///     initializer.
    public convenience init(rasterizationMode: GlyphsRasterizationMode = .ideographsRasterizedLocally,
                            fontFamilies: [String] = []) {
        // If rasterizationMode is .noGlyphsRasterizedLocally, we ignore the
        // font family
        guard rasterizationMode != .noGlyphsRasterizedLocally else {
            self.init(rasterizationMode: .noGlyphsRasterizedLocally, fontFamily: nil)
            return
        }

        let resolvedFamilies: [String]
        if fontFamilies.isEmpty {
            resolvedFamilies = Self.defaultFontFamilies()
        } else {
            resolvedFamilies = fontFamilies
        }
        let fontFamilies = resolvedFamilies.joined(separator: "\n")
        self.init(rasterizationMode: rasterizationMode, fontFamily: fontFamilies)
    }

    /// Return the default font family/families
    internal static func defaultFontFamilies() -> [String] {
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

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GlyphsRasterizationOptions else {
            return false
        }

        guard type(of: self) == type(of: other) else {
            return false
        }

        return
            (rasterizationMode == other.rasterizationMode) &&
            (fontFamily == other.fontFamily)
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(rasterizationMode)
        hasher.combine(fontFamily)
        return hasher.finalize()
    }
}
