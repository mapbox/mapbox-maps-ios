extension Array {
    static func testFixture(withLength length: UInt, generator: () -> Element) -> Self {
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
    static func testFixture() -> Self {
        .testFixture(withLength: 9, generator: { .randomASCII(withLength: 16) })
    }
}
