@testable import MapboxMaps

final class MockInterpolatedLocationProducer: InterpolatedLocationProducerProtocol {
    var location: InterpolatedLocation?

    let observeStub = Stub<(InterpolatedLocation) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }
}
