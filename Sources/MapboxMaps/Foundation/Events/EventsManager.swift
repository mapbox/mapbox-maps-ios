import UIKit
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

internal protocol EventsManagerProtocol: AnyObject {
    func sendMapLoadEvent()

    func sendTurnstile()

    func flush()
}

internal final class EventsManager: EventsManagerProtocol {
    private enum Constants {
        static let MGLAPIClientUserAgentBase = "mapbox-maps-ios"
        static let SDKVersion = Bundle.mapboxMapsMetadata.version
        static let UserAgent = String(format: "%/%", MGLAPIClientUserAgentBase, SDKVersion)
    }

    /// Responsible for location and telemetry metrics events
    private let telemetryService: TelemetryService

    /// Responsible for all the SDK interaction/feedback events
    private let eventsService: EventsService

    private let metricsEnabledObservation: NSKeyValueObservation

    internal init(accessToken: String) {
        let eventsServerOptions = EventsServerOptions(token: accessToken,
                                                      userAgentFragment: Constants.MGLAPIClientUserAgentBase,
                                                      deferredDeliveryServiceOptions: nil)
        eventsService = EventsService.getOrCreate(for: eventsServerOptions)
        telemetryService = TelemetryService.getOrCreate(for: eventsServerOptions)

        UserDefaults.standard.register(defaults: [
            #keyPath(UserDefaults.MGLMapboxMetricsEnabled): true
        ])

        metricsEnabledObservation = UserDefaults.standard.observe(\.MGLMapboxMetricsEnabled, options: [.initial, .new]) { _, change in
            DispatchQueue.main.async {
                guard let metricsEnabled = change.newValue else { return }

                TelemetryUtils.setEventsCollectionStateForEnableCollection(metricsEnabled)
            }
        }
    }

    private func getContentScale() -> Int {
        let sc = UIApplication.shared.preferredContentSizeCategory

        let defaultScale = -9999
        let scToScale: [UIContentSizeCategory: Int] = [
            .extraSmall: -3,
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

        return scToScale[sc] ?? defaultScale
    }

    private func getOrientation() -> String {
        let orientation = UIDevice.current.orientation

        let defaultOrientation = "Default - Unknown"
        let orientationToString: [UIDeviceOrientation: String] = [
            .unknown: "Unknown",
            .portrait: "Portrait",
            .portraitUpsideDown: "PortraitUpsideDown",
            .landscapeLeft: "LandscapeLeft",
            .landscapeRight: "LandscapeRight",
            .faceUp: "FaceUp",
            .faceDown: "FaceDown",
        ]

        return orientationToString[orientation] ?? defaultOrientation
    }

    private func lookupDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &model, &size, nil, 0)

        return String(cString: model)
    }

    private func getMapLoadEventAttributes() -> [String: Any] {
        let event = "map.load"
        let created = ISO8601DateFormatter().string(from: Date())
        let userId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let model = lookupDeviceModel()
        let operatingSystem = String(format: "%@ %@", UIDevice.current.systemName, UIDevice.current.systemVersion)
        let resolution = UIScreen.main.nativeScale
        let accessibilityFontScale = self.getContentScale()
        let orientation = self.getOrientation()
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
        let attributes = self.getMapLoadEventAttributes()
        let mapLoadEvent = MapboxCommon_Private.Event(priority: .queued,
                                                      attributes: attributes,
                                                      deferredOptions: nil)
        eventsService.sendEvent(for: mapLoadEvent)
    }

    internal func sendTurnstile() {
        let turnstileEvent = TurnstileEvent(skuId: UserSKUIdentifier.mapsMAUS,
                                            sdkIdentifier: Constants.MGLAPIClientUserAgentBase,
                                            sdkVersion: Constants.SDKVersion)
        eventsService.sendTurnstileEvent(for: turnstileEvent)
    }

    /// Flush events from internal telemetry and events services
    internal func flush() {
        telemetryService.flush()
        eventsService.flush()
    }

    deinit {
        flush()
    }
}
