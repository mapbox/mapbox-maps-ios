import UIKit

enum ConsolidatedAttributionPalette {
    /// Max chroma a tint can add, so the pill still looks neutral, not like a colored button.
    static let solidTintChroma: CGFloat = 0.14
    /// Higher, because half alpha over the map washes the tint out.
    static let translucentTintChroma: CGFloat = 0.22

    static func pill(_ material: ConsolidatedAttributionMaterial, tint: UIColor?) -> UIColor {
        let translucent = material == .translucent
        let maxChroma = translucent ? translucentTintChroma : solidTintChroma
        return UIColor { traits in
            guard traits.userInterfaceStyle != .dark else {
                // Too dark to show a tint without lightening it, so it stays neutral.
                return UIColor(white: 0.1, alpha: translucent ? 0.5 : 0.85)
            }
            let base = UIColor(white: 1, alpha: translucent ? 0.5 : 0.9)
            guard let tint else { return base }
            // Resolve inside the provider so a dynamic tint follows the interface style.
            return base.tinted(with: tint.resolvedColor(with: traits), maxChroma: maxChroma)
        }
    }

    static let content = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.9)
            : UIColor(white: 0, alpha: 0.7)
    }

    static let detail = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(white: 0.1, alpha: 1) : .white
    }

    /// Separate overlay, so a press doesn't change the pill's `backgroundColor`.
    static let highlight = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.18)
            : UIColor(white: 0, alpha: 0.12)
    }
}
