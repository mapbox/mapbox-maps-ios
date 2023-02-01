import MapboxMaps

final class MockViewportTransition: ViewportTransition {
    struct RunParams {
        var toState: ViewportState
        var completion: (Bool) -> Void
    }
    let runStub = Stub<RunParams, Cancelable>(defaultReturnValue: MockCancelable())
    func run(to toState: ViewportState,
             completion: @escaping (Bool) -> Void) -> Cancelable {
        runStub.call(with: .init(
            toState: toState,
            completion: completion))
    }
}
