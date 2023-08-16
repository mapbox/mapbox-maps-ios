struct BidirectionalMap<Key: Hashable, Value: Hashable> {
    private var keyToValue = [Key: Value]()
    private var valueToKey = [Value: Key]()

    subscript(key: Key) -> Value? {
        get {
            return keyToValue[key]
        }
        set {
            let oldValue = keyToValue[key]
            keyToValue[key] = newValue
            if let newValue = newValue {
                valueToKey[newValue] = key
            } else if let oldValue = oldValue {
                valueToKey[oldValue] = nil
            }
        }
    }

    subscript(value: Value) -> Key? {
        get {
            return valueToKey[value]
        }
        set {
            let newKey = newValue
            let oldKey = valueToKey[value]
            valueToKey[value] = newKey

            if let newKey = newKey {
                keyToValue[newKey] = value
            } else if let oldKey = oldKey {
                keyToValue[oldKey] = nil
            }
        }
    }
}
