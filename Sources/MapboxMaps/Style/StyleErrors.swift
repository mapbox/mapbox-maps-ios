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

/// Error type that represents the data returned with the `.mapLoadingError`
/// event
///
/// The associated message (which is returned by `errorDescription`) contains
/// a descriptive error message.
public enum MapLoadingError: LocalizedError {
    /// Style could not be loaded
    case style(String)

    /// Sprite could not be loaded
    case sprite(String)

    /// Source could not be loaded
    case source(String)

    /// Tile could not be loaded
    case tile(String)

    /// Glyphs could not be loaded
    case glyphs(String)

    internal init(data: Any) {
        guard let dictionary = data as? [String: Any],
              let type = dictionary["type"] as? String,
              let message = dictionary["message"] as? String else {
            fatalError("Invalid event data format")
        }

        self.init(type: type, message: message)
    }

    internal init(type: String, message: String) {
        switch type {
        case "style":
            self = .style(message)
        case "sprite":
            self = .sprite(message)
        case "source":
            self = .source(message)
        case "tile":
            self = .tile(message)
        case "glyphs":
            self = .glyphs(message)
        default:
            fatalError("Unknown map load error \(type):\(message)")
        }
    }

    /// Associated message (from `.mapLoadingError` event) that describes the
    /// error
    public var errorDescription: String? {
        switch self {
        case let .style(message):
            return message
        case let .sprite(message):
            return message
        case let .source(message):
            return message
        case let .tile(message):
            return message
        case let .glyphs(message):
            return message
        }
    }
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
