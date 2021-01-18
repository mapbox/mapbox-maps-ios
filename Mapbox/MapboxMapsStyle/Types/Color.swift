import UIKit

public typealias ColorRepresentable = String
extension ColorRepresentable {

    /// Create a string representation of a `UIColor`
    public init(color: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self = "rgba(\(red * 255.0), \(green * 255.0), \(blue * 255.0), \(alpha))"
    }
}

public extension UIColor {

    /// Initialize a `UIColor` from a `ColorRepresentable`
    convenience init?(hex: ColorRepresentable?) {
        guard let hex = hex else { return nil }

        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }

        return nil
    }
}

extension UIColor : ValidExpressionArgument {

    public var expressionElements: [Expression.Element] {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgbaExp = Exp(.rgba) {
            Double(red * 255.0)
            Double(green * 255.0)
            Double(blue * 255.0)
            Double(alpha)
        }
        return [.argument(.expression(rgbaExp))]
    }
}
