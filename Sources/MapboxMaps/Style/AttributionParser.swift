import Foundation

struct Attribution: Hashable {

    enum Style: CaseIterable {
        case regular
        case abbreviated
        case none
    }

    static let OSM                  = "OpenStreetMap"
    static let OSMAbbr              = "OSM"
    static let telemetrySettings    = "Telemetry Settings"
    static let aboutMapsURL         = URL(string: "https://www.mapbox.com/about/maps")!
    static let aboutTelemetryURL    = URL(string: "https://www.mapbox.com/telemetry")!

    var title: String
    var url: URL

    var titleAbbreviation: String {
        return title == Self.OSM ? Self.OSMAbbr : title
    }

    func snapshotTitle(for style: Style) -> String? {
        guard !isFeedbackURL else {
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

    static let improveMapURLs = [
        "https://www.mapbox.com/feedback/",
        "https://www.mapbox.com/map-feedback/",
        "https://apps.mapbox.com/feedback/"
    ]

    var isFeedbackURL: Bool {
        return title.lowercased() == "improve this map" ||
            Self.improveMapURLs.contains(url.absoluteString)
    }
}

//extension LogoView {
//    static func logoSize(for style: Attribution.Style) -> LogoSize? {
//        switch style {
//        case .long, .medium:
//            return .regular()
//
//        case .short:
//            return .compact()
//
//        case .none:
//            return nil
//        }
//    }
//}


class AttributionDelegate {
}


internal final class AttributionParser {

    internal static func parse(_ rawAttributions: [String]) -> [Attribution]  {

        var characterSet = CharacterSet(charactersIn: "©")
        characterSet.formUnion(.whitespacesAndNewlines)

        var attributions: [Attribution] = []

        for attributionString in rawAttributions {

            guard let htmlData = attributionString.data(using: .utf8) else {
                continue
            }

            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
                .documentType: NSAttributedString.DocumentType.html
            ]

            guard let attributedString = try? NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
                continue
            }



            attributedString.enumerateAttribute(.link,
                                                in: NSRange(location: 0, length: attributedString.length),
                                                options: []) { (value: Any?, range: NSRange, boolPointer: UnsafeMutablePointer<ObjCBool>) in
                guard let url = value as? URL else {
                    return
                }

                guard range.location != NSNotFound else {
                    return
                }


                let substring = attributedString.attributedSubstring(from: range)

                let trimmedString = substring.string.trimmingCharacters(in: characterSet)

                guard !trimmedString.isEmpty else {
                    return
                }

                let attribution = Attribution(title: trimmedString, url: url)

                if !attributions.contains(attribution) {
                    attributions.append(attribution)
                }
            }
        }

        return attributions
    }
}

class AttributionMeasure {

    func attributionThatFits(rect: CGRect, attributions: [Attribution], margin: CGFloat = 4) -> (Attribution.Style, LogoView.LogoSize?, NSAttributedString?) {

        let cases: [(LogoView.LogoSize, Attribution.Style)] = [
            (.regular(), .regular),
            (.compact(), .regular),
            (.compact(), .abbreviated),
            (.regular(), .none),
            (.compact(), .none),
            (.none, .none),
        ]


        for style in cases {

            var totalSize = CGSize.zero

            let logoSize = style.0
            if case .none = logoSize {
            } else {
                let imageSize = logoSize.size
                totalSize.width += margin + imageSize.width
                totalSize.height = imageSize.height
            }

            let text = attributionText(for: style.1, attributions: attributions)
            if let textSize = text?.size() {
                totalSize.width += margin + textSize.width + margin;
                totalSize.height = max(textSize.height, totalSize.height)
            }

            if (totalSize.width <= rect.width) && (totalSize.height <= rect.height) {
                return (style.1, logoSize, text)
            }
        }
        return (.none, nil, nil)
    }

    func attributionText(for style: Attribution.Style, attributions: [Attribution]) -> NSAttributedString? {
        let titleArray = attributions.compactMap { attribution in
            return attribution.snapshotTitle(for: style)
        }

        guard !titleArray.isEmpty else {
            return nil
        }

        let attributionText = "© \(titleArray.joined(separator: " / "))"
//        let font = UIFont(name: "GillSans-Light", size: UIFont.smallSystemFontSize)
        let font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .foregroundColor: UIColor.black//darkGray,
        ]

        let attributedText = NSAttributedString(string: attributionText, attributes: attributes)
        return attributedText
    }
}


final class AttributionView: UIView {//UIVisualEffectView {

    init(text: NSAttributedString) {
        // Label
        let label = UILabel()
        label.attributedText = text
        var labelSize = label.sizeThatFits(.zero)
        let labelOrigin = CGPoint(x: 10, y: 5)
        label.frame.origin = labelOrigin
        label.frame.size = labelSize

        // Effect view
//        let effect = UIBlurEffect(style: .light)
//        super.init(effect: effect)
        super.init(frame: .zero)

        labelSize.width += labelOrigin.x*2
        labelSize.height += labelOrigin.y*2

        frame = CGRect(origin: .zero, size: labelSize)
//        contentView.addSubview(label)
        addSubview(label)
//        backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.4)
        //tintColor = .red
        layer.cornerRadius = labelOrigin.x
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func draw(_ rect: CGRect) {

    }
}
