@testable import MapboxMaps

final class MockViewportImpl: ViewportImplProtocol {
    var status: ViewportStatus = .state(nil)

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
