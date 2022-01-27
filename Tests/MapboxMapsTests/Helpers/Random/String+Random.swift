extension String {
    static func randomASCII(withLength length: UInt) -> Self {
        return (0..<length).reduce(into: "") { s, _ in s.append(.randomASCII()) }
    }
}
