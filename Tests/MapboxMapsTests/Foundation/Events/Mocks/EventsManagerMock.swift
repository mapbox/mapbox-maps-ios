import UIKit
@testable import MapboxMaps

class EventsManagerMock: EventsManagerProtocol {

    @Stubbed var accessToken: String

    init(accessToken: String = "tests") {
        self.accessToken = accessToken
    }

    let sendMapLoadEventStub = Stub<UITraitCollection, Void>()
    func sendMapLoadEvent(with tratis: UITraitCollection) {
        sendMapLoadEventStub.call(with: tratis)
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
