import Foundation
@testable import MapboxMaps

class EventsManagerStub: EventsManagerProtocol {

    @Stubbed var accessToken: String

    init(accessToken: String = "tests") {
        self.accessToken = accessToken
    }

    static let sharedWithAccessTokenStub = Stub<String, EventsManagerProtocol>(defaultReturnValue: EventsManagerStub())
    static func shared(withAccessToken accessToken: String) -> MapboxMaps.EventsManagerProtocol {
        return EventsManagerStub(accessToken: accessToken)
    }

    let sendMapLoadEventStub = Stub<Void, Void>()
    func sendMapLoadEvent() {
        sendMapLoadEventStub.call()
    }

    let sendTurnstileStub = Stub<Void, Void>()
    func sendTurnstile() {
        sendTurnstileStub.call()
    }

    let flushStub = Stub<Void, Void>()
    func flush() {
        flushStub.call()
    }

    deinit {
        flush()
    }

}
