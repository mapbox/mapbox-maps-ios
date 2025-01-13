extension JSONObject {
    mutating func encode(key: String, value: Bool?) {
        if let value {
            self[key] = .boolean(value)
        }
    }

    mutating func encode(key: String, value: String?) {
        if let value {
            self[key] = .string(value)
        }
    }

    mutating func encode<T>(key: String, value: T?) where T: RawRepresentable, T.RawValue == String {
        encode(key: key, value: value?.rawValue)
    }
}
