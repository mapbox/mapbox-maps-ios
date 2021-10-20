import UIKit
import MapboxMobileEvents

extension UserDefaults {
    // dynamic var's name has to be the same as corresponding key in UserDefaults
    // to make KVO observing work properly
    @objc dynamic var MGLMapboxMetricsEnabled: Bool {
        get {
            return bool(forKey: #keyPath(MGLMapboxMetricsEnabled))
        }
        set {
            set(newValue, forKey: #keyPath(MGLMapboxMetricsEnabled))
        }
    }
}

internal class EventsManager: EventsListener {
    private enum Constants {
        static let MGLAPIClientUserAgentBase = "mapbox-maps-ios"
    }

    var telemetry: TelemetryProtocol!
    private var metricsEnabledObservation: NSKeyValueObservation?

    init(accessToken: String) {
        let sdkVersion = Bundle.mapboxMapsMetadata.version
        let mmeEventsManager = MMEEventsManager.shared()
        telemetry = mmeEventsManager
        mmeEventsManager.initialize(withAccessToken: accessToken,
                                    userAgentBase: Constants.MGLAPIClientUserAgentBase,
                                    hostSDKVersion: sdkVersion)
        mmeEventsManager.skuId = "00"

        metricsEnabledObservation = UserDefaults.standard.observe(\.MGLMapboxMetricsEnabled, options: [.initial, .new]) { _, change in
            DispatchQueue.main.async {
                guard let newValue = change.newValue else { return }
                UserDefaults.mme_configuration().mme_isCollectionEnabled = newValue
                MMEEventsManager.shared().pauseOrResumeMetricsCollectionIfRequired()
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }

    @objc func didReceiveMemoryWarning() {
        telemetry?.flush()
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
        case .custom(let customEvent):
            telemetry?.send(event: customEvent)
        }
    }

    private func process(mapEvent: EventType.Maps) {
        switch mapEvent {
        case .loaded:
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
