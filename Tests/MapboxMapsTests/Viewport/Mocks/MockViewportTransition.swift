import MapboxMaps

final class MockViewportTransition: ViewportTransition {

    struct RunParams {
        var fromState: ViewportState?
        var toState: ViewportState
        var completion: () -> Void
    }
    let runStub = Stub<RunParams, Cancelable>(defaultReturnValue: MockCancelable())
    func run(from fromState: ViewportState?,
             to toState: ViewportState,
             completion: @escaping () -> Void) -> Cancelable {
        runStub.call(with: .init(
            fromState: fromState,
            toState: toState,
            completion: completion))
    }
}
