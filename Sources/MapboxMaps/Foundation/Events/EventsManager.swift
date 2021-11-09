import UIKit
import MapboxMobileEvents
@_implementationOnly import MapboxCommon_Private

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
        static let SDKVersion = Bundle.mapboxMapsMetadata.version
        static let UserAgent = String(format: "%/%", MGLAPIClientUserAgentBase, SDKVersion)
    }

    var telemetry: TelemetryProtocol!
    var coreTelemetry: EventsService
    private var metricsEnabledObservation: NSKeyValueObservation?

    init(accessToken: String) {
        let mmeEventsManager = MMEEventsManager.shared()
        telemetry = mmeEventsManager
        mmeEventsManager.initialize(withAccessToken: accessToken,
                                    userAgentBase: Constants.MGLAPIClientUserAgentBase,
                                    hostSDKVersion: Constants.SDKVersion)
        mmeEventsManager.skuId = "00"

        
        let accessTokenCoreTelemetry = Bundle.main.infoDictionary?["MBXEventsServiceAccessToken"]  as? String ?? accessToken
        let baseUrl = Bundle.main.infoDictionary?["MBXEventsServiceURL"] as? String ?? nil
        
        let eventsServiceOptions = EventsServiceOptions(token: accessTokenCoreTelemetry, userAgentFragment: Constants.MGLAPIClientUserAgentBase, baseURL: baseUrl)
        coreTelemetry = EventsService(options: eventsServiceOptions)

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
            // MME events
            telemetry?.turnstile()
            telemetry?.send(event: mapEvent.typeString)
            
            // CoreTelemetry event
            let turnstileEvent = TurnstileEvent(skuId: SKUIdentifier.mapsMAUS, sdkIdentifier: Constants.MGLAPIClientUserAgentBase, sdkVersion: Constants.SDKVersion)
            coreTelemetry.sendTurnstileEvent(for: turnstileEvent)
                                                
            let ctEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: ["event": mapEvent.typeString])
            coreTelemetry.sendEvent(for: ctEvent)
        }
    }

    private func process(metricEvent: EventType.Metrics) {
        switch metricEvent {
        case .performance(let metrics):
            // MME events
            telemetry?.send(event: metricEvent.typeString, withAttributes: metrics)

            // CoreTelemetry event
            let ctEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: metrics)
            coreTelemetry.sendEvent(for: ctEvent, callback: nil)
        }
    }

    private func process(snapshotEvent: EventType.Snapshot) {
        switch snapshotEvent {
        case .initialized:
            // MME events
            telemetry?.turnstile()

            // CoreTelemetry event
            let turnstileEvent = TurnstileEvent(skuId: SKUIdentifier.mapsMAUS, sdkIdentifier: Constants.MGLAPIClientUserAgentBase, sdkVersion: Constants.SDKVersion)
            coreTelemetry.sendTurnstileEvent(for: turnstileEvent, callback: nil)
        }
    }

    private func process(offlineStorage: EventType.OfflineStorage) {
        switch offlineStorage {
        case .downloadStarted(let attributes):
            telemetry?.send(event: offlineStorage.typeString, withAttributes: attributes)

            let ctEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: attributes)
            coreTelemetry.sendEvent(for: ctEvent, callback: nil)
        }
    }
}

internal protocol TelemetryProtocol {
    func flush()
    func send(event: String)
    func send(event: String, withAttributes: [String: Any])
    func turnstile()
}
