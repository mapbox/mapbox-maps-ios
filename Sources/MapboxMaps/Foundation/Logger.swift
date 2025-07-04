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

    // MARK: - Logging levels
    /// Get the current logging level for a specific category or globally.
    /// - Parameter category: The logging category to check. If `nil`, returns the global logging level.
    /// - Returns: The current logging level. Returns `.debug` if no level is configured.
    @_spi(Logging) public static func loggingLevel(category: Category? = nil) -> LoggingLevel {
        let level: NSNumber?
        if let category {
            level = LogConfiguration.getLoggingLevel(forCategory: logCategory(category.rawValue))
        } else {
            level = LogConfiguration.getLoggingLevel()
        }
        return (level?.intValue).flatMap(LoggingLevel.init) ?? .debug
    }

    /// Set the logging level for a specific category or globally.
    /// - Parameters:
    ///   - level: The logging level to set.
    ///   - category: The logging category to configure. If `nil`, sets the global logging level.
    @_spi(Logging) public static func setLogging(level: LoggingLevel, category: Category? = nil) {
        let nsLevel = NSNumber(value: level.rawValue)
        if let category {
            LogConfiguration.setLoggingLevelForCategory(category.fullCategoryName, upTo: nsLevel)
        } else {
            LogConfiguration.setLoggingLevelForUpTo(nsLevel)
        }
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

        internal var fullCategoryName: String {
            Log.logCategory(rawValue)
        }
    }
}

@_spi(Logging) extension Log.Category {
    /// Category for application lifecycle events.
    public static let applicationLifecycle = Log.Category("ApplicationLifecycle")

    /// Category for size tracking layer events and operations.
    public static let sizeTrackingLayer = Log.Category("SizeTrackingLayer")
}
