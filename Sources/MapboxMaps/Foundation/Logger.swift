import Foundation
@_implementationOnly import MapboxCommon_Private.MBXLog_Internal

/// A logging utility with MapboxCommon backend by default.
@_spi(Logging) public struct Log {
    private typealias Logger = MapboxCommon_Private.Log

    private static func logCategory(_ additionalCategory: String?) -> String {
        let logPrefix = "maps-ios"
        guard let additionalCategory = additionalCategory, !additionalCategory.isEmpty else {
            return logPrefix
        }
        return "\(logPrefix)/\(additionalCategory)"
    }

    /// Log a debug message.
    @_spi(Logging) public static func debug(_ message: String, category: Category? = nil) {
        Logger.debug(forMessage: message, category: logCategory(category?.rawValue))
    }

    /// Log an info message.
    @_spi(Logging) public static func info(_ message: String, category: Category? = nil) {
        Logger.info(forMessage: message, category: logCategory(category?.rawValue))
    }

    /// Log a warning message.
    @_spi(Logging) public static func warning(_ message: String, category: Category? = nil) {
        Logger.warning(forMessage: message, category: logCategory(category?.rawValue))
    }

    /// Log an error message.
    @_spi(Logging) public static func error(_ message: String, category: Category? = nil) {
        Logger.error(forMessage: message, category: logCategory(category?.rawValue))
    }
}

extension Log {
    @_spi(Logging) public struct Category: RawRepresentable, ExpressibleByStringLiteral {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        init(_ value: String) {
            self.rawValue = value
        }

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }

        public init(unicodeScalarLiteral value: String) {
            self.rawValue = value
        }

        public init(extendedGraphemeClusterLiteral value: String) {
            self.rawValue = value
        }

        static let `default` = Category("")
    }

}
