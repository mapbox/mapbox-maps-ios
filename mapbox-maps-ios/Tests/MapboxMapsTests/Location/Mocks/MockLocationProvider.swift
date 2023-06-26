@testable import MapboxMaps

final class MockLocationProvider: LocationProvider {
    @Stubbed var latestLocation: Location?

    let addConsumerStub = Stub<LocationConsumer, Void>()
    func add(consumer: LocationConsumer) {
        addConsumerStub.call(with: consumer)
    }

    let removeConsumerStub = Stub<LocationConsumer, Void>()
    func remove(consumer: LocationConsumer) {
        removeConsumerStub.call(with: consumer)
    }

    func postLocationUpdate(_ location: Location) {
        let addedConsumers = addConsumerStub.invocations.map(\.parameters)
        let removedConsumers = removeConsumerStub.invocations.map(\.parameters)
        let activeConsumers = addedConsumers.filter { addedConsumer in
            !removedConsumers.contains(where: { $0 === addedConsumer})
        }

        for consumer in activeConsumers {
            consumer.locationUpdate(newLocation: location)
        }
    }
}

final class MockInterpolatedLocationProducer: InterpolatedLocationProducerProtocol {
    @Stubbed var locationProvider: LocationProvider = MockLocationProvider()

    var latestLocation: Location?
    var currentLocation: InterpolatedLocation?
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
