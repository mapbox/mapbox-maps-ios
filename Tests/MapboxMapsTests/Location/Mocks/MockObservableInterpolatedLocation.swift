@testable import MapboxMaps

final class MockObservableInterpolatedLocation: ObservableInterpolatedLocationProtocol {
    var value: InterpolatedLocation?

    let observeStub = Stub<(InterpolatedLocation) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }

    let notifyStub = Stub<InterpolatedLocation, Void>()
    func notify(with newValue: InterpolatedLocation) {
        notifyStub.call(with: newValue)
    }

    var onFirstSubscribe: (() -> Void)?

    var onLastUnsubscribe: (() -> Void)?
}
