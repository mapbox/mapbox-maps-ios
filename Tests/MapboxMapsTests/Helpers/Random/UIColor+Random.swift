import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: .random(in: 0...1))
    }

    static func testConstantValue() -> UIColor {
        return UIColor(
            red: 0.1,
            green: 0.2,
            blue: 0,
            alpha: 1)
    }
}
