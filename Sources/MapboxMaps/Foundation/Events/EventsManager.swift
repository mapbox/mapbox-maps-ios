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

internal final class EventsManager {
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

    private init(accessToken: String) {
        let sdkVersion = Bundle.mapboxMapsMetadata.version
        mmeEventsManager = .shared()
        mmeEventsManager.initialize(
            withAccessToken: accessToken,
            userAgentBase: "mapbox-maps-ios",
            hostSDKVersion: sdkVersion)
        mmeEventsManager.skuId = "00"

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
    }

    internal func sendMapLoadEvent() {
        mmeEventsManager.enqueueEvent(withName: MMEEventTypeMapLoad)
    }
}
