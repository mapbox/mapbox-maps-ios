import Foundation

extension TelemetryCounter: @unchecked Sendable {
    fileprivate static let sdkPrefix = "maps-mobile"
    fileprivate static let swiftUI = TelemetryCounter.create(name: "map", category: "swift-ui")
    fileprivate static let viewportCameraState = TelemetryCounter.viewport(name: "state/camera")
    fileprivate static let viewportFollowState = TelemetryCounter.viewport(name: "state/follow-puck")
    fileprivate static let viewportOverviewState = TelemetryCounter.viewport(name: "state/overview")
    fileprivate static let viewportTransition = TelemetryCounter.viewport(name: "transition")
    fileprivate static let styleDSL = TelemetryCounter.create(name: "dsl", category: "style")
    fileprivate static let carPlay = TelemetryCounter.create(forName: sdkPrefix + "/carplay")

    private static func viewport(name: String) -> TelemetryCounter {
        .create(name: name, category: "viewport")
    }

    private static func create(name: String, category: String) -> TelemetryCounter {
        .create(forName: [sdkPrefix, category, name].joined(separator: "/"))
    }
}

/// Default scope for telemetry events
/// This scope and all posible future scopes should be singleton to get rid of spawning several equal counters
/// Also singleton allows the usage of KeyPath in sendTelemetry (static members on metatype not allowed in KeyPath)
struct TelemetryEvents: Sendable {
    let swiftUI = TelemetryEvent(counter: .swiftUI)
    let viewportCameraState = TelemetryEvent(counter: .viewportCameraState)
    let viewportFollowState = TelemetryEvent(counter: .viewportFollowState)
    let viewportOverviewState = TelemetryEvent(counter: .viewportOverviewState)
    let viewportTransition = TelemetryEvent(counter: .viewportTransition)
    let styleDSL = TelemetryEvent(counter: .styleDSL)
    let carPlay = TelemetryEvent(counter: .carPlay)

    static let shared = TelemetryEvents()

    fileprivate init() {}
}

/// Abstraction over the actiual telemetry implementation, which hides all the implementtion details
/// All it's properties should be fileprivate to keep implementation inside the file
struct TelemetryEvent: Sendable {
    fileprivate let counter: TelemetryCounter
}

/// Interface for sending telemetry using the default events scope
/// Allows to send events in type-safe manner while keeping implementstion details hidden from client code
func sendTelemetry(_ eventName: KeyPath<TelemetryEvents, TelemetryEvent>) {
    sendTelemetry(eventName: eventName, category: TelemetryEvents.shared)
}

/// Interface for sending telemetry using the custom scope
/// Allows to send events in type-safe manner while keeping implementstion details hidden from client code and specify custom scope to group event when their number will grow
func sendTelemetry<T>(eventName: KeyPath<T, TelemetryEvent>, category: T) {
    let event = category[keyPath: eventName]
    event.counter.increment()
}
