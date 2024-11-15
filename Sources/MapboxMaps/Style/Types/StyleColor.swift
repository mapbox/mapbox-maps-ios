import UIKit
import RegexBuilder

/// Represents a color as defined by the [Mapbox Style Spec](https://docs.mapbox.com/style-spec/reference/types/#color)
public struct StyleColor: Codable, Hashable, Sendable, RawRepresentable, ExpressibleByStringInterpolation {

    /// A color string as defined by the [Mapbox Style Spec](https://docs.mapbox.com/style-spec/reference/types/#color).
    public let rawValue: String

    // MARK: - Component-wise

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    @available(*, unavailable, message: "Inspect color components by accessing the 'rawValue' property.")
    public var red: Double { fatalError() }

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    @available(*, unavailable, message: "Inspect color components by accessing the 'rawValue' property.")
    public var green: Double { fatalError() }

    /// A value from 0 to 255, as required by the Mapbox Style Spec
    @available(*, unavailable, message: "Inspect color components by accessing the 'rawValue' property.")
    public var blue: Double { fatalError() }

    /// Creates a `StyleColor` from individually-provided color components. Returns nil
    /// if any of the channel values are out of the supported ranges.
    /// - Parameters:
    ///   - red: A value from 0 to 255, as required by the Mapbox Style Spec
    ///   - green: A value from 0 to 255, as required by the Mapbox Style Spec
    ///   - blue: A value from 0 to 255, as required by the Mapbox Style Spec
    public init?(red: Double, green: Double, blue: Double) {
        guard [red, green, blue].allSatisfy((0.0...255.0).contains) else {
            return nil
        }
        self.rawValue = String(format: "rgb(%.2f, %.2f, %.2f)", red, green, blue)
    }

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
        self.rawValue = String(format: "rgba(%.2f, %.2f, %.2f, %.2f)", red, green, blue, alpha)
    }

    /// Creates a `StyleColor` from individually-provided color components. Returns nil
    /// if any of the channel values are out of the supported ranges.
    /// - Parameters:
    ///   - hue: A value from 0 to 360, as required by the Mapbox Style Spec
    ///   - saturation: A value from 0 to 100, as required by the Mapbox Style Spec
    ///   - lightness: A value from 0 to 100, as required by the Mapbox Style Spec
    public init?(hue: Double, saturation: Double, lightness: Double) {
        guard (0.0...360.0).contains(hue), [saturation, lightness].allSatisfy((0.0...100.0).contains) else {
            return nil
        }
        self.rawValue = String(format: "hsl(%.2f, %.2f, %.2f)", hue, saturation, lightness)
    }

    /// Creates a `StyleColor` from individually-provided color components. Returns nil
    /// if any of the channel values are out of the supported ranges.
    /// - Parameters:
    ///   - hue: A value from 0 to 360, as required by the Mapbox Style Spec
    ///   - saturation: A value from 0 to 100, as required by the Mapbox Style Spec
    ///   - lightness: A value from 0 to 100, as required by the Mapbox Style Spec
    ///   - alpha: A value from 0 to 1, as required by the Mapbox Style Spec
    public init?(hue: Double, saturation: Double, lightness: Double, alpha: Double) {
        guard (0.0...360.0).contains(hue), [saturation, lightness].allSatisfy((0.0...100.0).contains),
              (0.0...1.0).contains(alpha) else {
            return nil
        }
        self.rawValue = String(format: "hsla(%.2f, %.2f, %.2f, %.2f)", hue, saturation, lightness, alpha)
    }

    // MARK: - UIColor

    /// Creates a `StyleColor` from a `UIColor`
    /// - Parameter color: A `UIColor` in the sRGB color space
    public init(_ color: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        if let components = color.sRGBComponents, components.count == 4 {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        } else {
            Log.error("Failed to convert the color \(color) to sRGB color space. Falling back to black.")
        }

        self.rawValue = String(format: "rgba(%.2f, %.2f, %.2f, %.2f)", red * 255, green * 255, blue * 255, alpha)
    }

    // MARK: - Expression

    /// Creates a `StyleColor` from an `Exp`. Returns nil if
    /// the expression operator is not `rgb`, `rgba`, `hsl` or `hsla`, if the expression does not
    /// have four number-type arguments(for `rgba` and `hsla`) or three number-type arguments(for `rgb` and `hsl`),
    /// or if the arguments are out of the supported ranges.
    /// - Parameter expression: An rgb(a) or hsl(a)  expression.
    internal init?(expression: Exp) {
        guard case 3..<5 = expression.arguments.count,
              case .number(let component0) = expression.arguments[0],
              case .number(let component1) = expression.arguments[1],
              case .number(let component2) = expression.arguments[2] else {
            return nil
        }

        let alpha: Double?
        if expression.arguments.count >= 4, case .number(let a) = expression.arguments[3] {
            alpha = a
        } else {
            alpha = nil
        }

        switch (expression.operator, alpha) {
        case (.rgb, .none):
            self.init(red: component0, green: component1, blue: component2)
        case (.hsl, .none):
            self.init(hue: component0, saturation: component1, lightness: component2)
        case (.rgba, .some(let alpha)):
            self.init(red: component0, green: component1, blue: component2, alpha: alpha)
        case (.hsla, .some(let alpha)):
            self.init(hue: component0, saturation: component1, lightness: component2, alpha: alpha)
        default:
            return nil
        }
    }

    // MARK: - To/from string conversion

    /// Creates a `StyleColor` from a color string as defined in the [Mapbox Style Spec](https://docs.mapbox.com/style-spec/reference/types/#color).
    /// - Parameter rawValue: A color string.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    // MARK: - Codable

    /// `StyleColor` can be decoded from an rgba expression or from an rgba color string
    /// - Parameter decoder: The decoder from which the `StyleColor` will attempt
    /// to decode an rgba expression or rgba color string
    /// - Throws: Throws if neither an rgba expression nor an rbga color string could be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let optionalColor: StyleColor?
        if let expression = try? container.decode(Exp.self) {
            optionalColor = StyleColor(expression: expression)
        } else if let string = try? container.decode(String.self) {
            optionalColor = StyleColor(rawValue: string)
        } else {
            optionalColor = nil
        }
        guard let color = optionalColor else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected a color value as defined by the Mapbox Style Spec.")
        }
        self = color
    }

    /// `StyleColor` is always encoded to an rgba color string
    /// - Parameter encoder: The encoder to which the rgba color string is encoded
    /// - Throws: Throws if the provided encoder does not allow encoding the rgba color string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

private extension UIColor {
    var sRGBComponents: [CGFloat]? {
        guard let sRGBSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }
        return cgColor.converted(to: sRGBSpace, intent: .relativeColorimetric, options: nil)?.components
    }
}
