internal extension Encodable {
    /// Given an Encodable object return the JSON representation
    /// - Throws: Errors occurring during conversion.
    /// - Returns: A JSON value representing the object.
    func toJSON() throws -> Any {
        // wrap self in an array since encoding and decoding JSON
        // fragments is not supported on older iOS versions.
        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode([self]))

        // Since we know that the input was wrapped in an array, we can
        // count on the output also being wrapped in an array.
        // swiftlint:disable:next force_cast
        let array = object as! [Any]

        // Since we know that the input array had length 1, we can count
        // on `first` being non-nil
        return array.first!
    }

    /// Given an Encodable object return the JSON representation as a string
    /// - Throws: Errors occurring during conversion.
    /// - Returns: A string with JSON representing the object.
    func toString(encoding: String.Encoding = .utf8) throws -> String {
        let data: Data
        if #available(iOS 13.0, *) {
            data = try JSONEncoder().encode(self)
        } else {
            // JSONEncoder doesn't support fragments on older iOS versions https://github.com/apple/swift-corelibs-foundation/issues/4402
            data = try JSONSerialization.data(withJSONObject: self.toJSON(), options: .fragmentsAllowed)
        }

        guard let result = String(data: data, encoding: encoding) else {
            throw TypeConversionError.unsuccessfulConversion
        }

        return result
    }
}
