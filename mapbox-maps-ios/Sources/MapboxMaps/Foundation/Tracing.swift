import Foundation
import os
import MapboxCommon

private let subsystem = "com.mapbox.maps"

internal extension OSLog {
    @available(iOS 12, *)
    private static let _poi = OSLog(subsystem: subsystem, category: .pointsOfInterest)
    private static let _platform = OSLog(subsystem: subsystem, category: "platform")
    private static let tracingEnabled = setupTracing()

    static let platform: OSLog = tracingEnabled ? _platform : .disabled
    static let poi: OSLog = {
        if #available(iOS 12, *), tracingEnabled {
            return ._poi
        } else {
            return .disabled
        }
    }()

    /// Begins signpost interval. The returned `SignpostInterval` must be ended, preferably in `defer` block.
    func beginInterval(_ name: StaticString, beginMessage: String? = nil) -> SignpostInterval {
        let interval = SignpostInterval(log: self, name: name)
        interval.begin(message: beginMessage)
        return interval
    }

    /// Adds signpost event out of scope of any signpost interval. Usable to mark any points of interests, such as gestures.
    func signpostEvent(_ name: StaticString, message: String? = nil) {
        if #available(iOS 12, *) {
            signpost(.event, log: self, name: name, message: message)
        }
    }
}

/// Provides easy-to-use API for signposting intervals.
/// `SignpostInterval` can be seamlesly used from any iOS version, but will be reported only on iOS 12+.
internal struct SignpostInterval {
    private enum SignpostType {
        case begin
        case end
        case event

        @available(iOS 12, *)
        var asOSType: OSSignpostType {
            switch self {
            case .begin: return .begin
            case .end: return .end
            case .event: return .event
            }
        }
    }
    private typealias Call = (SignpostType, String?) -> Void
    private let call: Call?

    init(log: OSLog, name: StaticString) {
        if #available(iOS 12, *), log.signpostsEnabled {
            let id = OSSignpostID(log: log)
            call = {
                signpost($0.asOSType, log: log, name: name, signpostID: id, message: $1)
            }
        } else {
            call = nil
        }
    }

    fileprivate func begin(message: String? = nil) {
        call?(.begin, message)
    }

    func end(message: String? = nil) {
        call?(.end, message)
    }

    func event(message: String? = nil) {
        call?(.event, message)
    }
}

@available(iOS 12, *)
private func signpost(_ type: OSSignpostType, log: OSLog, name: StaticString, signpostID: OSSignpostID = .exclusive, message: String? = nil) {
    if let message = message {
        os_signpost(type, log: log, name: name, signpostID: signpostID, "%s", message)
    } else {
        os_signpost(type, log: log, name: name, signpostID: signpostID)
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
