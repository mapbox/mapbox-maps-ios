import Foundation

// Convenience methods and extensions for unit and integration tests

// MARK: - String

extension String: Error {

    /// Creates a new string that is suitable for saving to the file-system
    /// - Returns: new string
    func fileSystemSafeString() -> String {
        let invalidFileNameCharactersRegex = "[^a-zA-Z0-9_]+"
        let fullRange = startIndex..<endIndex
        let validName = replacingOccurrences(of: invalidFileNameCharactersRegex,
                                             with: "-",
                                             options: .regularExpression,
                                             range: fullRange)
        return validName
    }
}
