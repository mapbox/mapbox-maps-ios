import Foundation
import MapboxMobileEvents

extension MMEEventsManager: TelemetryProtocol {
    func send(event: String, withAttributes attributes: [String: Any]) {
        enqueueEvent(withName: event, attributes: attributes)
    }

    func send(event: String) {
        enqueueEvent(withName: event)
    }

    func turnstile() {
        sendTurnstileEvent()
    }
}
