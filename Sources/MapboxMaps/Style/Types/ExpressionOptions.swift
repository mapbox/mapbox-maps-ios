import Foundation

private enum ExpDecodingError: Error {
    case noKeysFound
}
extension Exp {

    public enum Option: Codable, Equatable, Sendable {
        case format(FormatOptions)
        case numberFormat(NumberFormatOptions)
        case collator(CollatorOptions)
        case image(ImageOptions)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validImageOptions = try? container.decode(ImageOptions.self) {
                self = .image(validImageOptions)

            } else if let validNumberFormatOptions = try? container.decode(NumberFormatOptions.self) {
                self = .numberFormat(validNumberFormatOptions)

            } else if let validFormatOptions = try? container.decode(FormatOptions.self) {
                self = .format(validFormatOptions)

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
            case .image(let option):
                try container.encode(option)
            }
        }

    }

}

public struct FormatOptions: Codable, Equatable, Sendable, ExpressionArgumentConvertible {

    /// Applies a scaling factor on text-size as specified by the root layout property.
    public var fontScale: Value<Double>?

    /// Overrides the font stack specified by the root layout property.
    public var textFont: Value<[String]>?

    /// Overrides the color specified by the root paint property.
    public var textColor: Value<StyleColor>?

    internal enum CodingKeys: String, CodingKey {
        case fontScale = "font-scale"
        case textFont = "text-font"
        case textColor = "text-color"
    }

    public var expressionArguments: [Exp.Argument] {
        return [.option(.format(self))]
    }

    public init(fontScale: Value<Double>? = nil, textFont: Value<[String]>? = nil, textColor: Value<StyleColor>? = nil) {
        self.fontScale = fontScale
        self.textFont = textFont
        self.textColor = textColor
    }

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lazy var isEmptyContainer = (try? decoder.container(keyedBy: AnyKey.self).allKeys.isEmpty) ?? container.allKeys.isEmpty

        guard container.containsAnyKey() ||
                isEmptyContainer // Preserve behavior of format options swallowing empty dictionaries
        else {
            throw ExpDecodingError.noKeysFound
        }

        fontScale = try container.decodeIfPresent(Value<Double>.self, forKey: .fontScale)
        textFont = try container.decodeIfPresent(Value<[String]>.self, forKey: .textFont)
        textColor = try container.decodeIfPresent(Value<StyleColor>.self, forKey: .textColor)
    }

}

public struct NumberFormatOptions: Codable, Equatable, ExpressionArgumentConvertible, Sendable {

    /// Specifies the locale to use, as a BCP 47 language tag.
    public var locale: String?

    /// Specifies an ISO 4217 code to use for currency-style formatting.
    public var currency: String?

    /// Minimum  number of fractional digits to include.
    public var minFractionDigits: Int?

    /// Maximum number of fractional digits to include.
    public var maxFractionDigits: Int?

    public var expressionArguments: [Exp.Argument] {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.containsAnyKey() else {
            throw ExpDecodingError.noKeysFound
        }

        locale = try container.decodeIfPresent(String.self, forKey: .locale)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        minFractionDigits = try container.decodeIfPresent(Int.self, forKey: .minFractionDigits)
        maxFractionDigits = try container.decodeIfPresent(Int.self, forKey: .maxFractionDigits)
    }
}

public struct CollatorOptions: Codable, Equatable, ExpressionArgumentConvertible, Sendable {

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

    public var expressionArguments: [Exp.Argument] {
        return [.option(.collator(self))]
    }

    public init(caseSensitive: Bool?, diacriticSensitive: Bool?, locale: String?) {
        self.caseSensitive = caseSensitive
        self.diacriticSensitive = diacriticSensitive
        self.locale = locale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.containsAnyKey() else {
            throw ExpDecodingError.noKeysFound
        }

        caseSensitive = try container.decodeIfPresent(Bool.self, forKey: .caseSensitive)
        diacriticSensitive = try container.decodeIfPresent(Bool.self, forKey: .diacriticSensitive)
        locale = try container.decodeIfPresent(String.self, forKey: .locale)
    }
}

/// Image options container.
public struct ImageOptions: Codable, Equatable, ExpressionArgumentConvertible, Sendable {
    public typealias ColorLike = Value<StyleColor>

    /// Vector image parameters.
    public var options: [String: ColorLike]

    public var expressionArguments: [Exp.Argument] {
        return [.option(.image(self))]
    }

    public init(_ options: [String: ColorLike]) {
        self.options = options
    }

    enum CodingKeys: String, CodingKey {
        case options = "params"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.containsAnyKey() else {
            throw ExpDecodingError.noKeysFound
        }

        options = try container.decode([String: ColorLike].self, forKey: .options)
    }
}

extension KeyedDecodingContainer {
    func containsAnyKey() -> Bool { allKeys.contains(where: contains) }

}
