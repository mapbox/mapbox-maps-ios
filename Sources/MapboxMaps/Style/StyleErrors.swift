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

/// Error type that represents the data returned with the `.mapLoadingError`
/// event
public enum MapLoadingError: LocalizedError {
    case style(String)

    case sprite(String)

    case source(String)

    case tile(String)

    case glyphs(String)

    internal init(data: Any) {
        guard let dictionary = data as? [String: String],
              let type = dictionary["type"],
              let message = dictionary["message"] else {
            fatalError("Invalid event data format")
        }

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

    public var errorDescription: String {
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
