import Foundation
import UIKit

extension UIColor {
    static var random: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }

    var darker: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }

        let v = 0.3

        return UIColor(red: max(r - v, 0.0),
                       green: max(g - v, 0.0),
                       blue: max(b - v, 0.0),
                       alpha: a)
    }
}
