@testable @_spi(Experimental) import MapboxMaps

final class MockViewportImpl: ViewportImplProtocol {
    @Stubbed var options: ViewportOptions = .random()

    @Stubbed var status: ViewportStatus = .random()

    let addStatusObserverStub = Stub<ViewportStatusObserver, Void>()
    func addStatusObserver(_ observer: ViewportStatusObserver) {
        addStatusObserverStub.call(with: observer)
    }

    let removeStatusObserverStub = Stub<ViewportStatusObserver, Void>()
    func removeStatusObserver(_ observer: ViewportStatusObserver) {
        removeStatusObserverStub.call(with: observer)
    }

    let idleStub = Stub<Void, Void>()
    func idle() {
        idleStub.call()
    }

    struct TransitionParams {
        var toState: ViewportState
        var transition: ViewportTransition?
        var completion: ((Bool) -> Void)?
    }
    let transitionStub = Stub<TransitionParams, Void>()
    func transition(to toState: ViewportState, transition: ViewportTransition?, completion: ((Bool) -> Void)?) {
        transitionStub.call(with: .init(
            toState: toState,
            transition: transition,
            completion: completion))
    }

    var defaultTransition: ViewportTransition = MockViewportTransition()
}
