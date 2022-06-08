@testable import MapboxMaps

final class MockInterpolatedLocationProducer: InterpolatedLocationProducerProtocol {
    var location: InterpolatedLocation?
    @Stubbed var isEnabled: Bool = true

    let observeStub = Stub<(InterpolatedLocation) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }

    let addPuckLocationConsumerStub = Stub<PuckLocationConsumer, Void>()
    func addPuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        addPuckLocationConsumerStub.call(with: consumer)
    }

    let removePuckLocationConsumerStub = Stub<PuckLocationConsumer, Void>()
    func removePuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        removePuckLocationConsumerStub.call(with: consumer)
    }
}
