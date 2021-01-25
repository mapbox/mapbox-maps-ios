import UIKit

/// Codable data structure that is used to represent platform colors to the map renderer
public struct ColorRepresentable: Codable, Equatable {

    /// UIColor value of the color representable
    public var uiColor: UIColor? {
        guard let hex = colorRepresentation else { return nil }

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

                    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
                }
            }
        }
        return nil
    }

    internal let colorRepresentation: String?

    /// Initialize a `ColorRepresentable` with a `UIColor`
    /// - Parameter color: A `UIColor` in sRGB color space
    /// - Returns: Returns a valid `ColorRepresentable` if initialized with a color in sRGB color space. Returns `nil` otherwise.
    public init?(color: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        let success = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        if !success {
            return nil
        }

        self.colorRepresentation = "rgba(\(red * 255.0), \(green * 255.0), \(blue * 255.0), \(alpha))"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(colorRepresentation)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.colorRepresentation = try container.decode(String.self)
    }
}

extension UIColor: ValidExpressionArgument {

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
