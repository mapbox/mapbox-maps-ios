extension Array {
    static func random(withLength length: UInt, generator: () -> Element) -> Self {
        return (0..<length).reduce(into: []) { array, _ in array.append(generator()) }
    }

    subscript(safe idx: Index) -> Element? {
        if idx >= startIndex, idx < endIndex {
            return self[idx]
        }
        return nil
    }
}

extension Array where Element == String {
    static func random(withMinLength minLength: UInt = 0) -> Self {
        .random(withLength: .random(in: minLength...10), generator: { .randomASCII(withLength: .random(in: 0...20)) })
    }
}
