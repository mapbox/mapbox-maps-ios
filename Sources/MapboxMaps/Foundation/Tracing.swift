import Foundation
import os
import MapboxCommon

private let subsystem = "com.mapbox.maps"

internal enum SignpostName {
    static let mapViewDisplayLink: StaticString = "MapView.displayLink"
}

internal extension OSLog {
    private static let _poi = OSLog(subsystem: subsystem, category: .pointsOfInterest)
    private static let _platform = OSLog(subsystem: subsystem, category: "platform")
    private static let tracingEnabled = setupTracing()

    static let platform: OSLog = tracingEnabled ? _platform : .disabled
    static let poi: OSLog = {
        if tracingEnabled {
            return ._poi
        } else {
            return .disabled
        }
    }()

    /// Adds signpost event out of scope of any signpost interval. Usable to mark any points of interests, such as gestures.
    func signpostEvent(_ name: StaticString, message: String? = nil) {
        if #available(iOS 15, *) {
            OSSignposter(logHandle: self).emitEvent(name)
        } else {
            signpost(.event, log: self, name: name, message)
        }
    }

    func beginInterval(_ name: StaticString, beginMessage: String? = nil) -> SignpostInterval? {
        guard OSLog.tracingEnabled else { return nil }

        let intervalType = classForSignpostInterval()
        return intervalType.init(log: self,
                                 intervalName: name,
                                 message: beginMessage)
    }

    func withIntervalSignpost<T>(_ name: StaticString, _ message: String? = nil, around task: () throws -> T) rethrows -> T {
        let interval = beginInterval(name, beginMessage: message)
        defer { interval?.end() }

        return try task()
    }

    private func classForSignpostInterval() -> SignpostInterval.Type {
        if #available(iOS 15, *) {
            return SignpostIntervalV15.self
        }
        return SignpostIntervalV12.self
    }
}

/// Provides easy-to-use API for signposting intervals.
internal protocol SignpostInterval {
    init(log: OSLog, intervalName: StaticString, message: String?)
    func end()
    func end(message: String?)
}

extension SignpostInterval {
    func end() {
        end(message: nil)
    }
}

internal struct SignpostIntervalV12: SignpostInterval {
    let log: OSLog
    let intervalName: StaticString
    let signpostID: OSSignpostID

    init(log: OSLog, intervalName: StaticString, message: String?) {
        self.log = log
        self.intervalName = intervalName
        self.signpostID = OSSignpostID(log: log)

        signpost(.begin, log: log, name: intervalName, signpostID: signpostID, message)
    }

    func end(message: String?) {
        signpost(.end, log: log, name: intervalName, signpostID: signpostID, message)
    }
}

private func signpost(_ type: OSSignpostType, log: OSLog, name: StaticString, signpostID: OSSignpostID = .exclusive, _ message: String? = nil) {
    if let message = message {
        os_signpost(type, log: log, name: name, signpostID: signpostID, "%s", message)
    } else {
        os_signpost(type, log: log, name: name, signpostID: signpostID)
    }
}

@available(iOS 15.0, *)
internal struct SignpostIntervalV15: SignpostInterval {
    let signposter: OSSignposter
    let intervalName: StaticString
    let intervalState: OSSignpostIntervalState

    init(log: OSLog, intervalName: StaticString, message: String?) {
        signposter = OSSignposter(logHandle: log)
        let signpostID = OSSignpostID(log: log)
        self.intervalName = intervalName

        if let message = message {
            intervalState = signposter.beginInterval(intervalName, id: signpostID,
                                                     "\(message)")
        } else {
            intervalState = signposter.beginInterval(intervalName, id: signpostID)
        }
    }

    func end(message: String?) {
        if let message = message {
            signposter.endInterval(intervalName, intervalState, "\(message)")
        } else {
            signposter.endInterval(intervalName, intervalState)
        }
    }
}

private func setupTracing() -> Bool {
    let isEnabled = ProcessInfo.processInfo.environment.keys.contains("MAPBOX_MAPS_SIGNPOSTS_ENABLED")
    if isEnabled {
        // Enable tracing in Core
        let settings = SettingsServiceFactory.getInstance(storageType: .nonPersistent)
        _ = settings.set(key: "com.mapbox.tracing", value: [subsystem: "platform"])
    }
    return isEnabled
}
