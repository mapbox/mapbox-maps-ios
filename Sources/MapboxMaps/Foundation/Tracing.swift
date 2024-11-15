import Foundation
import os
import MapboxCommon

private let subsystem = "com.mapbox.maps"

internal enum SignpostName {
    static let mapViewDisplayLink: StaticString = "MapView.displayLink"
}

/// Enable `os_signpost` generation in some components
///
/// By default, signpost generation is disabled. It's possible to enable some components with ``Tracing/status`` API.
///
/// The `MAPBOX_MAPS_SIGNPOSTS_ENABLED` environment variable can be used to manipulate the initial value of the tracing status
/// There are a few rules for environment variable:
/// 1. The empty value will enable all components tracing. Equals to ``enabled``.
/// 2. The value of `0` or `disabled` will set a default value to ``disabled``.
/// 3. All other values will be processed as a component names and be enabled accordingly.
/// The comma `,` delimiter has to be used to pass multiple components (e.g. `"core,platform"`).
/// 4. Value is case-insensitive.
public struct Tracing: OptionSet {
    /// No tracing logs will be generated
    public static let disabled = Tracing([])

    /// Traces related to Maps SDK will be generated
    public static let platform = Tracing(rawValue: 1 << 0)

    /// Traces related to the rendering engine will be generated
    public static let core = Tracing(rawValue: 1 << 1)

    /// Enable all known components to generate traces.
    public static let enabled: Tracing = [.core, .platform]

    /// Environment variable name to change the default tracing value
    public static let environmentVariableName = "MAPBOX_MAPS_SIGNPOSTS_ENABLED"

    /// Change tracing generation logic in runtime.
    public static var status: Tracing = .runtimeValue() {
        didSet {
            Tracing.updateCore(tracing: status)
        }
    }

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    internal typealias EnvironmentVariableProvider = (String) -> String?

    internal static let disableTracingKeys = ["0", "disabled"]

    internal static let enableTracingKeys = ["1", "enabled"]

    internal static func runtimeValue(
        provider: EnvironmentVariableProvider = { ProcessInfo.processInfo.environment[$0] }
    ) -> Tracing {
        let value = calculateRuntimeValue(provider: provider)
        Tracing.updateCore(tracing: value)
        return value
    }

    internal static func calculateRuntimeValue(provider: EnvironmentVariableProvider) -> Tracing {
        guard let envValue = provider(environmentVariableName)?.lowercased(),
              !disableTracingKeys.contains(envValue) else {
            return .disabled
        }

        guard !envValue.isEmpty, !enableTracingKeys.contains(envValue) else { return .enabled }

        return envValue.split(separator: ",")
            .map({ $0.trimmingCharacters(in: .whitespaces) }).filter({ !$0.isEmpty })
            .reduce(into: Tracing(), { tracing, component in
                switch component {
                case "core": tracing.insert(.core)
                case "platform": tracing.insert(.platform)
                default: Log.info("Unrecognized tracing option: \(component)", category: "Tracing")
                }
            })
    }

    internal static func updateCore(tracing: Tracing) {
        CoreTracing.setTracingBackendTypeFor(tracing.contains(.core) ? .platform : .noop)
    }
}

internal extension OSLog {
    private static let _poi = OSLog(subsystem: subsystem, category: .pointsOfInterest)
    private static let _platform = OSLog(subsystem: subsystem, category: "platform")

    static var platform: OSLog {
        Tracing.status.contains(.platform) ? _platform : .disabled
    }

    static var poi: OSLog {
        Tracing.status.contains(.platform) ? _poi : .disabled
    }

    /// Adds signpost event out of scope of any signpost interval. Usable to mark any points of interests, such as gestures.
    func signpostEvent(_ name: StaticString, message: String? = nil) {
        if #available(iOS 15, *) {
            let signposter = OSSignposter(logHandle: self)
            if let message = message {
                signposter.emitEvent(name, "\(message)")
            } else {
                signposter.emitEvent(name, "\(name)")
            }
        } else {
            signpost(.event, log: self, name: name, message)
        }
    }

    func beginInterval(_ name: StaticString, beginMessage: String? = nil) -> SignpostInterval? {
        guard Tracing.status.contains(.platform) else { return nil }

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
        os_signpost(type, log: log, name: name, signpostID: signpostID, name)
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
