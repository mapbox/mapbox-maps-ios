import Foundation
@_implementationOnly import MapboxCommon_Private.MBXLog_Internal

internal struct Log {
    private typealias Logger = MapboxCommon_Private.Log

    private static func logCategory(_ additionalCategory: String?) -> String {
        let logPrefix = "maps-ios"
        guard let additionalCategory = additionalCategory else {
            return logPrefix
        }
        return "\(logPrefix)/\(additionalCategory)"
    }

    internal static func debug(forMessage message: String, category: String? = nil) {
        Logger.debug(forMessage: message, category: logCategory(category))
    }

    internal static func info(forMessage message: String, category: String? = nil) {
        Logger.info(forMessage: message, category: logCategory(category))
    }

    internal static func warning(forMessage message: String, category: String? = nil) {
        Logger.warning(forMessage: message, category: logCategory(category))
    }

    internal static func error(forMessage message: String, category: String? = nil) {
        Logger.error(forMessage: message, category: logCategory(category))
    }
}
