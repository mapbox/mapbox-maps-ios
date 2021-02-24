import UIKit
import MapboxMobileEvents

internal class EventsManager: EventsListener {
    private enum Constants {
        static let MGLAPIClientUserAgentBase = "mapbox-maps-ios"
    }

    var telemetry: TelemetryProtocol!

    init(accessToken: String) {
        let sdkVersion = "10.0.0"
        let mmeEventsManager = MMEEventsManager.shared()
        telemetry = mmeEventsManager
        mmeEventsManager.initialize(withAccessToken: accessToken,
                                    userAgentBase: Constants.MGLAPIClientUserAgentBase,
                                    hostSDKVersion: sdkVersion)
    }

    init(with telemetry: TelemetryProtocol?) {
        self.telemetry = telemetry
    }

    func push(event: EventType) {
        switch event {
        case .map(let mapEvent):
            process(mapEvent: mapEvent)
        case .metrics(let metricsEvent):
            process(metricEvent: metricsEvent)
        case .snapshot(let snapshotEvent):
            process(snapshotEvent: snapshotEvent)
        case .offlineStorage(let offlineStorageEvent):
            process(offlineStorage: offlineStorageEvent)
        case .memoryWarning:
            telemetry?.flush()
        case .custom(let customEvent):
            telemetry?.send(event: customEvent)
        }
    }

    private func process(mapEvent: EventType.Maps) {
        switch mapEvent {
        case .mapLoaded:
            telemetry?.turnstile()
            telemetry?.send(event: mapEvent.typeString)
        case .mapPausedRendering:
            telemetry?.flush()
        case .mapResumedRendering:
            telemetry?.turnstile()
            telemetry?.send(event: mapEvent.typeString)
        }
    }

    private func process(metricEvent: EventType.Metrics) {
        switch metricEvent {
        case .performance(let metrics):
            telemetry?.send(event: metricEvent.typeString, withAttributes: metrics)
        }
    }

    private func process(snapshotEvent: EventType.Snapshot) {
        switch snapshotEvent {
        case .initialized:
            telemetry?.turnstile()
        }
    }

    private func process(offlineStorage: EventType.OfflineStorage) {
        switch offlineStorage {
        case .downloadStarted(let attributes):
            telemetry?.send(event: offlineStorage.typeString, withAttributes: attributes)
        }
    }
}

internal protocol TelemetryProtocol {
    func flush()
    func send(event: String)
    func send(event: String, withAttributes: [String: Any])
    func turnstile()
}
