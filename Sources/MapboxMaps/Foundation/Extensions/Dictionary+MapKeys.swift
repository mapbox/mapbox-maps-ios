internal extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] {
        // swiftlint:disable:next syntactic_sugar
        Dictionary<T, Value>(uniqueKeysWithValues: map { (kv) -> (T, Value) in
            (transform(kv.key), kv.value)
        })
    }
}
