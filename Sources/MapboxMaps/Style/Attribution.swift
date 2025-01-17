import Foundation
import WebKit
@_implementationOnly import MapboxCommon_Private

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

        guard let url = url else {
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

    /// Parse the raw attribution strings from sources asynchronously
    /// - Parameter rawAttributions: Array of HTML strings
    /// - Parameter completion: A block that will be passed the result of parsing.
    internal static func parse(_ rawAttributions: [String], completion: @escaping ([Attribution]) -> Void) {
#if compiler(>=5.6.0) && canImport(_Concurrency)
        Task { @MainActor in
            let attributons = await parseAsync(rawAttributions)
            completion(attributons)
        }
#else
        completion(parseSynchronously(rawAttributions))
#endif
    }

#if compiler(>=5.6.0) && canImport(_Concurrency)
    /// Parse the raw attribution strings from sources asynchronously
    /// - Parameter rawAttributions: Array of HTML strings
    /// - Returns: Array of Attribution structs
    private static func parseAsync(_ rawAttributions: [String]) async -> [Attribution] {
        var result: [Attribution] = []

        for attributionString in rawAttributions {
            guard let attributedString = try? await NSAttributedString.fromHTML(attributionString).0 else {
                continue
            }

            result.append(contentsOf: attributedString.attributions)
        }

        // Disallow duplicates.
        // swiftlint:disable:next force_cast
        return NSOrderedSet(array: result).array as! [Attribution]
    }
#endif

    /// Parse the raw attribution strings from sources synchronously.
    /// Known for intermittent crashes - https://developer.apple.com/forums/thread/115405?answerId=356326022#356326022
    ///
    /// - Parameter rawAttributions: Array of HTML strings
    /// - Returns: Array of Attribution structs
    private static func parseSynchronously(_ rawAttributions: [String]) -> [Attribution] {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
            .documentType: NSAttributedString.DocumentType.html
        ]

        let attributions = rawAttributions
            .compactMap { $0.data(using: .utf8) }
            .compactMap { try? NSAttributedString(data: $0, options: options, documentAttributes: nil) }
            .flatMap(\.attributions)

        // Disallow duplicates.
        // swiftlint:disable:next force_cast
        return NSOrderedSet(array: attributions).array as! [Attribution]
    }
}

fileprivate extension NSAttributedString {
    var attributions: [Attribution] {
        let characterSet = CharacterSet(charactersIn: "©").union(.whitespacesAndNewlines)
        var attributions: [Attribution] = []

        enumerateAttribute(.link,
                           in: NSRange(location: 0, length: length),
                           options: []) { (value: Any?, range: NSRange, _: UnsafeMutablePointer<ObjCBool>) in
            guard range.location != NSNotFound else {
                return
            }

            let substring = attributedSubstring(from: range).string
            let trimmedString = substring.trimmingCharacters(in: characterSet)

            guard !trimmedString.isEmpty else {
                return
            }

            let attribution = Attribution(title: trimmedString, url: value as? URL)
            attributions.append(attribution)
        }

        return attributions
    }
}
