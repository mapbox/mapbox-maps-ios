import UIKit
import MapboxMobileEvents
@_implementationOnly import MapboxCommon_Private

internal class EventsManager: EventsListener {
    private enum Constants {
        static let MGLAPIClientUserAgentBase = "mapbox-maps-ios"
        static let SDKVersion = "10.0.0"
        static let UserAgent = String(format: "%/%", MGLAPIClientUserAgentBase, SDKVersion)
    }

    var telemetry: TelemetryProtocol!
    var coreTelemetry: EventsService

    init(accessToken: String) {
        let mmeEventsManager = MMEEventsManager.shared()
        telemetry = mmeEventsManager
        mmeEventsManager.initialize(withAccessToken: accessToken,
                                    userAgentBase: Constants.MGLAPIClientUserAgentBase,
                                    hostSDKVersion: Constants.SDKVersion)
        mmeEventsManager.skuId = "00"

        let eventsServiceOptions = EventsServiceOptions(token: accessToken, userAgentFragment: Constants.UserAgent, baseURL: nil)
        coreTelemetry = EventsService(options: eventsServiceOptions)
    }

    func push(event: EventType) {
        switch event {
        case .map(let mapEvent):
            process(mapEvent: mapEvent)
        case .memoryWarning:
            telemetry?.flush()
        }
    }

    private func process(mapEvent: EventType.Maps) {
        switch mapEvent {
        case .loaded:
            telemetry?.turnstile()
            telemetry?.send(event: mapEvent.typeString)
            let turnstileEvent = TurnstileEvent(skuId: SKUIdentifier.mapsMAUS, sdkIdentifier: Constants.MGLAPIClientUserAgentBase, sdkVersion: Constants.SDKVersion)
            coreTelemetry.sendTurnstileEvent(for: turnstileEvent, callback: nil)
        }
    }
}

internal protocol TelemetryProtocol {
    func flush()
    func send(event: String)
    func send(event: String, withAttributes: [String: Any])
    func turnstile()
}
