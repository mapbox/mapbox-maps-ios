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

    fileprivate func getContentScale() -> Int {
        let sc = UIApplication.shared.preferredContentSizeCategory

        let defalutScale = -9999
        let scToScale = [
            UIContentSizeCategory.extraSmall: -3,
            .small: -2,
            .medium: -1,
            .large: 0,
            .extraLarge: 1,
            .extraExtraLarge: 2,
            .extraExtraExtraLarge: 3,
            .accessibilityMedium: -11,
            .accessibilityLarge: 10,
            .accessibilityExtraLarge: 11,
            .accessibilityExtraExtraLarge: 12,
            .accessibilityExtraExtraExtraLarge: 13
        ]

        return scToScale[sc] ?? defalutScale
    }

    fileprivate func getModel() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &model, &size, nil, 0)

        return String(cString: model)
    }

    fileprivate func getMapLoadEventAttributes() -> [String: Any] {
        let event = "map.load"
        let created = ISO8601DateFormatter().string(from: Date())
        let userId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let model = self.getModel()
        let operatingSystem = String(format: "%@ %@", UIDevice.current.systemName, UIDevice.current.systemVersion)
        let resolution = UIScreen.main.nativeScale
        let accessibilityFontScale = self.getContentScale()
        let orientation = UIDevice.current.orientation
        let wifi = ReachabilityFactory.reachability(forHostname: nil).currentNetworkStatus() == .reachableViaWiFi

        let eventAttributes = [
            "event": event,
            "created": created,
            "userId": userId,
            "model": model,
            "operatingSystem": operatingSystem,
            "resolution": resolution,
            "accessibilityFontScale": accessibilityFontScale,
            "orientation": orientation,
            "wifi": wifi
        ] as [String: Any]

        return eventAttributes
    }

    internal func sendMapLoadEvent() {
        mmeEventsManager.enqueueEvent(withName: MMEEventTypeMapLoad)

        let attributes = self.getMapLoadEventAttributes()
        let ctEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: attributes, deferredOptions: nil)
        coreTelemetry.sendEvent(for: ctEvent)
    }
}
