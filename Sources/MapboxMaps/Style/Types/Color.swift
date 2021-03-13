import UIKit

/// Container to represent `UIColor`for use by the map renderer
public struct ColorRepresentable: Codable, Equatable {

    /// Expression representation of a `UIColor` used by the renderer
    public let colorRepresentation: Expression?

    /// `UIColor` instance represented by this `ColorRepresentable`
    public var uiColor: UIColor? {

        if case let .op(rgbaOp) = colorRepresentation?.elements[0],
           rgbaOp == .rgba, // operator must be `rgba`
           case let .argument(.number(red)) = colorRepresentation?.elements[1],    // red
           case let .argument(.number(green)) = colorRepresentation?.elements[2],  // green
           case let .argument(.number(blue)) = colorRepresentation?.elements[3],   // blue
           case let .argument(.number(alpha)) = colorRepresentation?.elements[4] { // alpha

            // Color components are in the range of 0-255 for use in the renderer,
            // but `UIColor` requires color components in the range of 0-1.
            // So we must divide each color component by 255 before (re)creating the `UIColor`.
            // NOTE: Alpha values are expected to in the range of 0-1 across the renderer and `UIKit` constructs.
            return UIColor(red: CGFloat(red / 255.0),
                           green: CGFloat(green / 255.0),
                           blue: CGFloat(blue / 255.0),
                           alpha: CGFloat(alpha))
        }

        return nil
    }

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
            // Renderer requires color components to be in the range of 0-255
            // So we must multply each component by 255 in order for the renderer
            // to honor the color.
            colorRepresentation = Exp(.rgba) {
                Double(red * 255.0)
                Double(green * 255.0)
                Double(blue * 255.0)
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
        colorRepresentation = try container.decode(Expression.self)
    }
}

extension UIColor: ValidExpressionArgument {

    public var expressionElements: [Expression.Element] {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgbaExp = Exp(.rgba) {
            Double(red * 255.0)
            Double(green * 255.0)
            Double(blue * 255.0)
            Double(alpha)
        }
        return [.argument(.expression(rgbaExp))]
    }
}
