extension String {
    // Convenience that returns a string with most of the string redacted
    internal func redacted(indent: Int = 4) -> String {
        let offset = min(indent, count)
        let start = index(startIndex, offsetBy: offset)
        let result = replacingCharacters(in: start...,
                                         with: String(repeating: "×", count: count - offset))
        return result
    }
}
