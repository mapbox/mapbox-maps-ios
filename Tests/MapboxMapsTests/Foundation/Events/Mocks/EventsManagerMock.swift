import UIKit
@testable @_spi(Restricted) import MapboxMaps

class EventsManagerMock: EventsManagerProtocol {

    @Stubbed var accessToken: String

    init(accessToken: String = "tests") {
        self.accessToken = accessToken
    }

    let sendMapLoadEventStub = Stub<(traits: UITraitCollection, uiFramework: UIFramework), Void>()
    func sendMapLoadEvent(with traits: UITraitCollection, uiFramework: UIFramework) {
        sendMapLoadEventStub.call(with: (traits, uiFramework))
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
