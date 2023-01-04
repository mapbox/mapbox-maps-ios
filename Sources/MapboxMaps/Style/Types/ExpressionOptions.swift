import UIKit

extension Expression {

    public enum Option: Codable, Equatable {
        case format(FormatOptions)
        case numberFormat(NumberFormatOptions)
        case collator(CollatorOptions)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validFormatOptions = try? container.decode(FormatOptions.self) {
                self = .format(validFormatOptions)

            } else if let validNumberFormatOptions = try? container.decode(NumberFormatOptions.self) {
                self = .numberFormat(validNumberFormatOptions)

            } else if let validCollatorOptions = try? container.decode(CollatorOptions.self) {
                self = .collator(validCollatorOptions)

            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                    debugDescription: "Failed to decode ExpressionOption")
                throw DecodingError.dataCorrupted(context)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .collator(let option):
                try container.encode(option)
            case .format(let option):
                try container.encode(option)
            case .numberFormat(let option):
                try container.encode(option)
            }
        }

    }

}

public struct FormatOptions: Codable, Equatable, ExpressionArgumentConvertible {

    /// Applies a scaling factor on text-size as specified by the root layout property.
    public var fontScale: Double?
    /// Applies a scaling factor on text-size as specified by the root layout property.
    /// If specified, this value will override ``fontScale`` when encoding.
    public var fontScaleExpression: Expression?

    /// Overrides the font stack specified by the root layout property
    public var textFont: [String]?
    /// Overrides the font stack specified by the root layout property
    /// If specified, this value will override ``textFont`` when encoding.
    public var textFontExpression: Expression?

    /// Overrides the color specified by the root paint property.
    public var textColor: StyleColor?
    /// Overrides the color specified by the root paint property.
    /// If specified, this value will override ``textColor`` when encoding.
    public var textColorExpression: Expression?

    internal enum CodingKeys: String, CodingKey {
        case fontScale = "font-scale"
        case textFont = "text-font"
        case textColor = "text-color"
    }

    public var expressionArguments: [Expression.Argument] {
        return [.option(.format(self))]
    }

    public init(fontScale: Double? = nil, textFont: [String]? = nil, textColor: UIColor? = nil) {
        self.fontScale = fontScale
        self.textFont = textFont

        if let textColor = textColor {
            self.textColor = StyleColor(textColor)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decodeIfPresent(Value<Double>.self, forKey: .fontScale) {
        case .constant(let fontScale): self.fontScale = fontScale
        case .expression(let expression): self.fontScaleExpression = expression
        case .none: break
        }

        switch try container.decodeIfPresent(Value<[String]>.self, forKey: .textFont) {
        case .constant(let textFonts): self.textFont = textFonts
        case .expression(let expression): self.textFontExpression = expression
        case .none: break
        }

        switch try container.decodeIfPresent(Value<StyleColor>.self, forKey: .textColor) {
        case .constant(let textColor): self.textColor = textColor
        case .expression(let expression): self.textColorExpression = expression
        case .none: break
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let fontScaleExpression = fontScaleExpression {
            try container.encode(fontScaleExpression, forKey: .fontScale)
        } else {
            try container.encodeIfPresent(fontScale, forKey: .fontScale)
        }

        if let textFontExpression = textFontExpression {
            try container.encode(textFontExpression, forKey: .textFont)
        } else {
            try container.encodeIfPresent(textFont, forKey: .textFont)
        }

        if let textColorExpression = textColorExpression {
            try container.encode(textColorExpression, forKey: .textColor)
        } else {
            try container.encodeIfPresent(textColor, forKey: .textColor)
        }
    }
}

public struct NumberFormatOptions: Codable, Equatable, ExpressionArgumentConvertible {

    /// Specifies the locale to use, as a BCP 47 language tag.
    public var locale: String?

    /// Specifies an ISO 4217 code to use for currency-style formatting.
    public var currency: String?

    /// Minimum  number of fractional digits to include.
    public var minFractionDigits: Int?

    /// Maximum number of fractional digits to include.
    public var maxFractionDigits: Int?

    public var expressionArguments: [Expression.Argument] {
        return [.option(.numberFormat(self))]
    }

    internal enum CodingKeys: String, CodingKey {
        case locale = "locale"
        case currency = "currency"
        case minFractionDigits = "min-fraction-digits"
        case maxFractionDigits = "max-fraction-digits"
    }

    public init(locale: String?, currency: String?, minFractionDigits: Int?, maxFractionDigits: Int?) {
        self.locale = locale
        self.currency = currency
        self.minFractionDigits = minFractionDigits
        self.maxFractionDigits = maxFractionDigits
    }
}

public struct CollatorOptions: Codable, Equatable, ExpressionArgumentConvertible {

    /// Whether comparison option is case sensitive.
    public var caseSensitive: Bool?

    /// Whether the comparison operation is diacritic sensitive
    public var diacriticSensitive: Bool?

    /// The locale argument specifies the IETF language tag of the locale to use.
    /// If none is provided, the default locale is used.
    public var locale: String?

    internal enum CodingKeys: String, CodingKey {
        case locale = "locale"
        case caseSensitive = "case-sensitive"
        case diacriticSensitive = "diacritic-sensitive"
    }

    public var expressionArguments: [Expression.Argument] {
        return [.option(.collator(self))]
    }

    public init(caseSensitive: Bool?, diacriticSensitive: Bool?, locale: String?) {
        self.caseSensitive = caseSensitive
        self.diacriticSensitive = diacriticSensitive
        self.locale = locale
    }

}
