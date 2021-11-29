import UIKit

/// Represents a color as defined by the Mapbox Style Spec
public struct StyleColor: Codable, Equatable {

    // MARK: - Component-wise

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    public let red: Double

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    public let green: Double

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    public let blue: Double

    /// A value from 0 to 1, as required by the Mapbox Style Spec
    public let alpha: Double

    /// Creates a `StyleColor` from individually-provided color components. Returns nil
    /// if any of the channel values are out of the supported ranges.
    /// - Parameters:
    ///   - red: A value from 0 to 255, as required by the Mapbox Style Spec
    ///   - green: A value from 0 to 255, as required by the Mapbox Style Spec
    ///   - blue: A value from 0 to 255, as required by the Mapbox Style Spec
    ///   - alpha: A value from 0 to 1, as required by the Mapbox Style Spec
    public init?(red: Double, green: Double, blue: Double, alpha: Double) {
        guard [red, green, blue].allSatisfy((0.0...255.0).contains),
              (0.0...1.0).contains(alpha) else {
            return nil
        }
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    // MARK: - UIColor

    /// Creates a `StyleColor` from a `UIColor`
    /// - Parameter color: A `UIColor` in the sRGB color space
    public init(_ color: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha),
              [red, green, blue, alpha].allSatisfy((0.0...1.0).contains) else {
            fatalError("Please use a color in the sRGB color space")
        }
        self.red = Double(red * 255)
        self.green = Double(green * 255)
        self.blue = Double(blue * 255)
        self.alpha = Double(alpha)
    }

    // MARK: - Expression

    /// Creates a `StyleColor` from an `Expression`. Returns nil if
    /// the expression operator is not `rgba`, if the expression does not
    /// have four number-type arguments, or if the arguments are out of
    /// the supported ranges.
    /// - Parameter expression: An rgba expression
    internal init?(expression: Expression) {
        guard case .rgba = expression.operator,
              expression.arguments.count == 4,
              case .number(let red) = expression.arguments[0],
              case .number(let green) = expression.arguments[1],
              case .number(let blue) = expression.arguments[2],
              case .number(let alpha) = expression.arguments[3] else {
            return nil
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    // MARK: - RGBA String

    /// Creates a `StyleColor` from an rgba color string as defined
    /// in the Mapbox Style Spec. Returns nil if the string is not a valid
    /// rgba color string.
    /// - Parameter rgbaString: An rgba color string
    internal init?(rgbaString: String) {
        let nsString = NSString(string: rgbaString)
        let numberRegex = "(-?(?:0|[1-9][0-9]*)(?:.[0-9]+)?(?:[eE][+-]?[0-9]+)?)"
        let regex = try! NSRegularExpression(pattern: "^ *rgba\\( *\(numberRegex) *, *\(numberRegex) *, *\(numberRegex) *, *\(numberRegex) *\\) *$", options: [])
        let matches = regex.matches(in: rgbaString, options: [], range: NSRange(location: 0, length: nsString.length))
        guard matches.count == 1, let firstMatch = matches.first else {
            return nil
        }
        let redString = nsString.substring(with: firstMatch.range(at: 1))
        let greenString = nsString.substring(with: firstMatch.range(at: 2))
        let blueString = nsString.substring(with: firstMatch.range(at: 3))
        let alphaString = nsString.substring(with: firstMatch.range(at: 4))
        guard let red = Double(redString),
              let green = Double(greenString),
              let blue = Double(blueString),
              let alpha = Double(alphaString) else {
            return nil
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// An rgba color string in the form `rgba(red, green, blue, alpha)` as defined by the Mapbox Style Spec
    internal var rgbaString: String {
        return "rgba(\(red), \(green), \(blue), \(alpha))"
    }

    // MARK: - Codable

    /// `StyleColor` can be decoded from an rgba expression or from an rgba color string
    /// - Parameter decoder: The decoder from which the `StyleColor` will attempt
    /// to decode an rgba expression or rgba color string
    /// - Throws: Throws if neither an rgba expression nor an rbga color string could be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let optionalColor: StyleColor?
        if let expression = try? container.decode(Expression.self) {
            optionalColor = StyleColor(expression: expression)
        } else if let string = try? container.decode(String.self) {
            optionalColor = StyleColor(rgbaString: string)
        } else {
            optionalColor = nil
        }
        guard let color = optionalColor else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected rgba expression or rgba color value as defined by the Mapbox Style Spec.")
        }
        self = color
    }

    /// `StyleColor` is always encoded to an rgba color string
    /// - Parameter encoder: The encoder to which the rgba color string is encoded
    /// - Throws: Throws if the provided encoder does not allow encoding the rgba color string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rgbaString)
    }
}
