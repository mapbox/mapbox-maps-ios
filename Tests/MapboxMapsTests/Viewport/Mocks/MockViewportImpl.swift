@testable import MapboxMaps

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
        var completion: ((Bool) -> Void)?
    }
    let transitionStub = Stub<TransitionParams, Void>()
    func transition(to toState: ViewportState, completion: ((Bool) -> Void)?) {
        transitionStub.call(with: .init(toState: toState, completion: completion))
    }

    var defaultTransition: ViewportTransition = MockViewportTransition()

    struct SetTransitionParams {
        var transition: ViewportTransition
        var fromState: ViewportState?
        var toState: ViewportState
    }
    let setTransitionStub = Stub<SetTransitionParams, Void>()
    func setTransition(_ transition: ViewportTransition, from fromState: ViewportState?, to toState: ViewportState) {
        setTransitionStub.call(with: .init(transition: transition, fromState: fromState, toState: toState))
    }

    struct GetTransitionParams {
        var fromState: ViewportState?
        var toState: ViewportState
    }
    let getTransitionStub = Stub<GetTransitionParams, ViewportTransition?>(defaultReturnValue: nil)
    func getTransition(from fromState: ViewportState?, to toState: ViewportState) -> ViewportTransition? {
        getTransitionStub.call(with: .init(fromState: fromState, toState: toState))
    }

    struct RemoveTransitionParams {
        var fromState: ViewportState?
        var toState: ViewportState
    }
    let removeTransitionStub = Stub<RemoveTransitionParams, Void>()
    func removeTransition(from fromState: ViewportState?, to toState: ViewportState) {
        removeTransitionStub.call(with: .init(fromState: fromState, toState: toState))
    }
}
