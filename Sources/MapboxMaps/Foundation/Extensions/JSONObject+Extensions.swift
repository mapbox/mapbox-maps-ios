extension JSONObject {
    mutating func encode(key: String, value: Bool?) {
        if let value {
            self[key] = .boolean(value)
        }
    }

    mutating func encode<T>(key: String, value: T?) where T: RawRepresentable, T.RawValue == String {
        if let value {
            self[key] = .string(value.rawValue)
        }
    }
}
