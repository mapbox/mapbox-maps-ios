import Foundation

// MARK: - Style error types

/// Type of errors thrown by the `Style` APIs.
public struct StyleError: RawRepresentable, LocalizedError {
    /// :nodoc:
    public typealias RawValue = String

    /// :nodoc:
    public var rawValue: String

    /// :nodoc:
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    internal init(message: String) {
        self.rawValue = message
    }

    /// Error message
    public var errorDescription: String? {
        return rawValue
    }
}

public enum TypeConversionError: Error {
    case invalidJSONObject
    case unexpectedType
}
