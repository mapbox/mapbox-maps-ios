import Foundation

internal struct Attribution: Hashable {

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

    /// Parse the raw attribution strings from sources
    /// - Parameter rawAttributions: Array of HTML strings
    /// - Returns: Array of Attribution structs
    static func parse(_ rawAttributions: [String]) -> [Attribution] {

        var characterSet = CharacterSet(charactersIn: "©")
        characterSet.formUnion(.whitespacesAndNewlines)

        var attributions: [Attribution] = []

        for attributionString in rawAttributions {

            guard let htmlData = attributionString.data(using: .utf8) else {
                continue
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
                .documentType: NSAttributedString.DocumentType.html
            ]

            guard let attributedString = try? NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
                continue
            }

            attributedString.enumerateAttribute(.link,
                                                in: NSRange(location: 0, length: attributedString.length),
                                                options: []) { (value: Any?, range: NSRange, _: UnsafeMutablePointer<ObjCBool>) in
                guard range.location != NSNotFound else {
                    return
                }

                let substring = attributedString.attributedSubstring(from: range).string
                let trimmedString = substring.trimmingCharacters(in: characterSet)

                guard !trimmedString.isEmpty else {
                    return
                }

                let attribution = Attribution(title: trimmedString, url: value as? URL)

                // Disallow duplicates.
                if !attributions.contains(attribution) {
                    attributions.append(attribution)
                }
            }
        }

        return attributions
    }
}
