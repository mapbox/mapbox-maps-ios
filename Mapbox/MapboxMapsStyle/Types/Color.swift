import UIKit

/// Container to represent `UIColor`for use by the map renderer
public struct ColorRepresentable: Codable, Equatable {

    /// String representation of a `UIColor` used by the renderer
    public let colorRepresentation: String?

    /// Create a string representation of a `UIColor`
    /// - Parameter color: A `UIColor` instance in the sRGB color space
    /// - Returns: Initializes a `ColorRepresentable` instance if the `color` is in sRGB color space. Returns `nil` otherwise.
    public init?(color: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.colorRepresentation = "rgba(\(red * 255.0), \(green * 255.0), \(blue * 255.0), \(alpha))"
        } else {
            return nil
        }
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
