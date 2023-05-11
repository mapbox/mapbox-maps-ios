import Foundation

// MARK: - Style error types

/// Type of errors thrown by the `Style` APIs.
public struct StyleError: RawRepresentable, LocalizedError {
    public typealias RawValue = String

    public var rawValue: String

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
    case invalidObject
    case unexpectedType
    case unsuccessfulConversion
}

/// Type of errors thrown by the `MapboxMap` APIs.
public struct MapError: LocalizedError, CoreErrorRepresentable {
    internal typealias CoreErrorType = NSString

    /// Error message
    public private(set) var errorDescription: String

    internal init(coreError: NSString) {
        errorDescription = coreError as String
    }
}
