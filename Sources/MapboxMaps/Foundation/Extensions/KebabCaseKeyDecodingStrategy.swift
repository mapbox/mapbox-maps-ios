import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    internal static var convertFromKebabCase: Self {
        return .custom { keys in
            let lastKey = keys.last!.stringValue.camelCased

            return AnyKey(stringValue: lastKey)!
        }
    }
}

private struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

private extension String {
    var camelCased: String {
        return lowercased()
            .split(separator: "-")
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
}
