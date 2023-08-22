internal struct AttributionMeasure {

    private init() {}

    /// Determine the appropriate logo and attribution text that fits in a given rect
    ///
    /// - Parameters:
    ///   - rect: Rect that logo and attribution should fit within
    ///   - attributions: Array of `Attribution`
    ///   - margin: Margin used to the left of the logo, and around attribution
    ///         text
    /// - Returns: Tuple of logo "size" and the attribution text (or nil if it
    ///         can't)
    static func logoAndAttributionThatFits(rect: CGRect, attributions: [Attribution], margin: CGFloat) -> (LogoView.LogoSize, NSAttributedString?) {
        let options: [(LogoView.LogoSize, Attribution.Style)] = [
            (.regular(), .regular),
            (.compact(), .regular),
            (.compact(), .abbreviated),
            (.regular(), .none),
            (.compact(), .none),
            (.none, .none),
        ]

        // TODO: Consider replacing this with layout constraint version (and
        // LogoView and AttributionView that automatically modify their content)
        for pair in options {
            var totalSize = CGSize.zero

            // Check the logo
            let logoSize = pair.0
            if logoSize != .none {
                let imageSize = logoSize.size
                totalSize.width += margin + imageSize.width
                totalSize.height = imageSize.height
            }

            // Check attribution
            let text = Attribution.text(for: attributions, style: pair.1)
            if let textSize = text?.size() {
                totalSize.width += (2 * margin) + (2 * AttributionView.padding.x) + textSize.width
                totalSize.height = max(textSize.height, totalSize.height)
            }

            if (totalSize.width <= rect.width) && (totalSize.height <= rect.height) {
                return (logoSize, text)
            }
        }
        return (.none, nil)
    }
}
