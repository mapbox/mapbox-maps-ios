import UIKit

/// Container to represent `UIColor`for use by the map renderer
public struct ColorRepresentable: Codable, Equatable {

    /// Expression representation of a `UIColor` used by the renderer
    public let colorRepresentation: Expression?

    /// Create a string representation of a `UIColor`
    /// - Parameter color: A `UIColor` instance in the sRGB color space
    /// - Returns: Initializes a `ColorRepresentable` instance if the `color` is in sRGB color space.
    public init(color: UIColor) {

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        let success = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let validColorComponents = Self.isValidColor(red: red, green: red, blue: blue, alpha: alpha)
        if success && validColorComponents {
            self.colorRepresentation = Exp(.rgba) {
                Double(red)
                Double(green)
                Double(blue)
                Double(alpha)
            }
        } else {
            fatalError("Please use a color in the sRGB color space")
        }
    }

    /// Checks if all color components are within the 0-1 range
    internal static func isValidColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> Bool {
        let validRange = 0.0...1.0
        return validRange ~= Double(red)
            && validRange ~= Double(green)
            && validRange ~= Double(blue)
            && validRange ~= Double(alpha)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(colorRepresentation)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.colorRepresentation = try container.decode(Expression.self)
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
