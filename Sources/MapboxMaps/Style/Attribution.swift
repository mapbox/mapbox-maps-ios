import Foundation
import UIKit
internal import MapboxCommon_Private

struct Attribution: Hashable {

    enum Style: CaseIterable {
        case regular
        case abbreviated
        case none
    }

    enum Kind: Hashable {
        case feedback
        case actionable(URL)
        case nonActionable
    }

    // Feedback URLs
    private static let improveMapURLs = [
        "https://www.mapbox.com/feedback/",
        "https://www.mapbox.com/map-feedback/",
        "https://apps.mapbox.com/feedback/"
    ]
    internal static let privacyPolicyURL = URL(string: "https://www.mapbox.com/legal/privacy#product-privacy-policy")!

    var title: String
    var kind: Kind

    var titleAbbreviation: String {
        return title == "OpenStreetMap" ? "OSM" : title
    }

    func snapshotTitle(for style: Style) -> String? {
        guard kind != .feedback else {
            return nil
        }

        switch style {
        case .regular:
            return title

        case .abbreviated:
            return titleAbbreviation

        case .none:
            return nil
        }
    }

    static func makePrivacyPolicyAttribution() -> Attribution {
        let title = NSLocalizedString("ATTRIBUTION_PRIVACY_POLICY",
                                      tableName: Ornaments.localizableTableName,
                                      bundle: .mapboxMaps,
                                      value: "Mapbox Privacy Policy",
                                      comment: "Privacy policy action in attribution sheet")
        return .init(title: title, url: Self.privacyPolicyURL)
    }

    internal init(title: String, url: URL?) {
        self.title = title

        guard let url, Self.isWebScheme(url) else {
            self.kind = .nonActionable
            return
        }

        let isFeedback = title.lowercased() == "improve this map" ||
        Self.improveMapURLs.contains(url.absoluteString)

        self.kind = isFeedback ? .feedback : .actionable(url)
    }

    /// Return a combined text for attributions, intended for use with Snapshotters
    /// (via AttributionView)
    ///
    /// - Parameters:
    ///   - attributions: Array of attributions
    ///   - style: Whether attribution should be abbreviated or not
    /// - Returns: NSAttributedString or nil if not appropriate
    static func text(for attributions: [Attribution], style: Attribution.Style) -> NSAttributedString? {
        let titleArray = attributions.compactMap { $0.snapshotTitle(for: style) }

        guard !titleArray.isEmpty && style != .none else {
            return nil
        }

        let attributionText = "© \(titleArray.joined(separator: " / "))"

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
            .foregroundColor: UIColor(white: 0.2, alpha: 1.0),
        ]

        return NSAttributedString(string: attributionText, attributes: attributes)
    }

    /// Parse the raw attribution strings from sources.
    ///
    /// Each string is treated as a restricted HTML fragment containing only
    /// `<a href="...">text</a>` anchors and surrounding plain text. No HTML
    /// importer is invoked — anchors are extracted with a regex and the
    /// remaining markup is stripped. This is deliberate: handing these
    /// strings (which originate from operator-controlled TileJSON
    /// `attribution` fields) to `NSAttributedString`'s HTML reader would
    /// cause the WebKit-backed importer to fetch any referenced subresource.
    ///
    /// Invariants this parser deliberately enforces (see MAPSIOS-2192):
    /// - Only anchors with **quoted** `href` (`"…"` or `'…'`) are
    ///   recognised. Unquoted forms like `<a href=javascript:alert(1)>x</a>`
    ///   do not match `anchorRegex` and fall through to the plain-text
    ///   path, where the whole string becomes a single `.nonActionable`
    ///   Attribution. Quoting is universal in real tileset attribution, so
    ///   rejecting unquoted hrefs avoids a tolerant URL extractor that
    ///   could be tricked into surfacing dangerous schemes as actionable.
    /// - Only `http`/`https` URLs become `.actionable`; every other scheme
    ///   (`javascript:`, `data:`, `file:`, …) downgrades to `.nonActionable`
    ///   in `init(title:url:)`.
    /// - `<img>`, `<link>`, `<style>` and other non-anchor markup never
    ///   reaches an HTML parser, so no subresource fetching can originate
    ///   from this code path.
    ///
    /// - Parameter rawAttributions: Array of attribution strings.
    /// - Returns: Deduplicated array of Attribution structs.
    internal static func parse(_ rawAttributions: [String]) -> [Attribution] {
        var seen: Set<Attribution> = []
        var result: [Attribution] = []

        for raw in rawAttributions {
            for attribution in parseOne(raw) where seen.insert(attribution).inserted {
                result.append(attribution)
            }
        }

        return result
    }

    // MARK: - Internals

    /// Defense-in-depth cap on attribution string size; real attribution
    /// strings are tens of characters.
    private static let maxInputLength = 16 * 1024

    private static let anchorRegex: NSRegularExpression = {
        let pattern = #"<a\b[^>]*\bhref\s*=\s*(?:"([^"]*)"|'([^']*)')[^>]*>(.*?)</a>"#
        // swiftlint:disable:next force_try
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
    }()

    private static let tagRegex: NSRegularExpression = {
        // swiftlint:disable:next force_try
        return try! NSRegularExpression(pattern: "<[^>]+>", options: [.dotMatchesLineSeparators])
    }()

    private static let trimCharacterSet = CharacterSet(charactersIn: "©").union(.whitespacesAndNewlines)

    /// `&amp;` must be decoded last so we don't double-decode `&amp;copy;`.
    private static let htmlEntities: [(String, String)] = [
        ("&copy;", "©"),
        ("&lt;", "<"),
        ("&gt;", ">"),
        ("&quot;", "\""),
        ("&apos;", "'"),
        ("&#39;", "'"),
        ("&nbsp;", " "),
        ("&amp;", "&")
    ]

    private static func parseOne(_ raw: String) -> [Attribution] {
        guard !raw.isEmpty else { return [] }

        guard raw.utf8.count <= maxInputLength else {
            Log.warning(
                "Attribution string exceeds \(maxInputLength)-byte hard cap (\(raw.utf8.count) bytes); dropping. " +
                "Real tileset attribution strings are tens of characters — investigate the source.",
                category: "Attribution"
            )
            return []
        }

        let fullRange = NSRange(raw.startIndex..., in: raw)
        let matches = anchorRegex.matches(in: raw, options: [], range: fullRange)

        guard !matches.isEmpty else {
            let title = normalize(stripTags(raw))
            return title.isEmpty ? [] : [Attribution(title: title, url: nil)]
        }

        var attributions: [Attribution] = []
        for match in matches {
            guard let innerRange = Range(match.range(at: 3), in: raw) else { continue }
            let title = normalize(stripTags(String(raw[innerRange])))
            guard !title.isEmpty else { continue }

            let hrefRange = Range(match.range(at: 1), in: raw) ?? Range(match.range(at: 2), in: raw)
            let url = hrefRange
                .map { decodeEntities(String(raw[$0])) }
                .flatMap(URL.init(string:))
            attributions.append(Attribution(title: title, url: url))
        }
        return attributions
    }

    private static func stripTags(_ s: String) -> String {
        let range = NSRange(s.startIndex..., in: s)
        return tagRegex.stringByReplacingMatches(in: s, options: [], range: range, withTemplate: "")
    }

    private static func decodeEntities(_ s: String) -> String {
        var out = s
        for (entity, replacement) in htmlEntities where out.contains(entity) {
            out = out.replacingOccurrences(of: entity, with: replacement)
        }
        return out
    }

    private static func normalize(_ s: String) -> String {
        decodeEntities(s).trimmingCharacters(in: trimCharacterSet)
    }

    private static func isWebScheme(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "https" || scheme == "http"
    }
}
