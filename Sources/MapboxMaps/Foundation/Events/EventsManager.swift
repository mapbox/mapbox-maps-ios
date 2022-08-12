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

internal final class EventsManager {
    private enum Constants {
            static let userAgentBase = "mapbox-maps-ios"
            static let sdkVersion = Bundle.mapboxMapsMetadata.version
        }
    // use a shared instance to avoid redundant calls to
    // MMEEventsManager.shared().pauseOrResumeMetricsCollectionIfRequired()
    // when the MGLMapboxMetricsEnabled UserDefaults key changes and duplicate
    // calls to MMEEventsManager.shared().flush() when handling memory warnings.
    private static var shared: EventsManager?

    internal static func shared(withAccessToken accessToken: String) -> EventsManager {
        let result = shared ?? EventsManager(accessToken: accessToken)
        shared = result
        return result
    }

    private let mmeEventsManager: MMEEventsManager

    private let metricsEnabledObservation: NSKeyValueObservation

    private let coreTelemetry: EventsService
    private let telemetryService: TelemetryService

    private init(accessToken: String) {
        mmeEventsManager = .shared()
        mmeEventsManager.initialize(
            withAccessToken: accessToken,
            userAgentBase: Constants.userAgentBase,
            hostSDKVersion: Constants.sdkVersion)
        mmeEventsManager.skuId = "00"

        let accessTokenCoreTelemetry = Bundle.main.infoDictionary?["MBXEventsServiceAccessToken"]  as? String ?? accessToken

        let eventsServerOptions = EventsServerOptions(token: accessTokenCoreTelemetry, userAgentFragment: Constants.userAgentBase, deferredDeliveryServiceOptions: nil)
        coreTelemetry = EventsService.getOrCreate(for: eventsServerOptions)
        telemetryService = TelemetryService.getOrCreate(for: eventsServerOptions)

        UserDefaults.standard.register(defaults: [
            #keyPath(UserDefaults.MGLMapboxMetricsEnabled): true
        ])

        metricsEnabledObservation = UserDefaults.standard.observe(\.MGLMapboxMetricsEnabled, options: [.initial, .new]) { [mmeEventsManager] _, change in
            DispatchQueue.main.async {
                guard let metricsEnabled = change.newValue else { return }
                UserDefaults.mme_configuration().mme_isCollectionEnabled = metricsEnabled
                mmeEventsManager.pauseOrResumeMetricsCollectionIfRequired()
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil)
    }

    @objc private func didReceiveMemoryWarning() {
        mmeEventsManager.flush()
    }

    internal func sendTurnstile() {
        mmeEventsManager.sendTurnstileEvent()

        let turnstileEvent = TurnstileEvent.init(skuId: UserSKUIdentifier.mapsMAUS, sdkIdentifier: Constants.userAgentBase, sdkVersion: Constants.sdkVersion)
        coreTelemetry.sendTurnstileEvent(for: turnstileEvent)
    }

    internal func sendMapLoadEvent() {
        mmeEventsManager.enqueueEvent(withName: MMEEventTypeMapLoad)

        let ctEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: ["event": MMEEventTypeMapLoad], deferredOptions: nil)
        coreTelemetry.sendEvent(for: ctEvent)
    }
}
