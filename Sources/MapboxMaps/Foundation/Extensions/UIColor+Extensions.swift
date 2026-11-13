import UIKit

extension UIColor {
    /// Takes `tint`'s hue, keeps this color's brightness and alpha.
    ///
    /// - Parameter maxChroma: Max saturation times brightness.
    func tinted(with tint: UIColor, maxChroma: CGFloat) -> UIColor {
        var tintHue: CGFloat = 0, tintSaturation: CGFloat = 0
        var brightness: CGFloat = 0, alpha: CGFloat = 0
        guard tint.getHue(&tintHue, saturation: &tintSaturation, brightness: nil, alpha: nil),
              getHue(nil, saturation: nil, brightness: &brightness, alpha: &alpha),
              brightness > 0 else {
            return self
        }
        let chroma = min(tintSaturation, maxChroma)
        return UIColor(hue: tintHue,
                       saturation: min(1, chroma / brightness),
                       brightness: brightness,
                       alpha: alpha)
    }
}
