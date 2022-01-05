@testable import MapboxMaps

final class MockLocationProducer: LocationProducerProtocol {
    weak var delegate: LocationProducerDelegate?

    var latestLocation: Location?

    var headingOrientation: CLDeviceOrientation = .portrait

    var consumers = NSHashTable<LocationConsumer>.weakObjects()

    let didSetLocationProviderStub = Stub<LocationProvider, Void>()
    var locationProvider: LocationProvider = MockLocationProvider() {
        didSet {
            didSetLocationProviderStub.call(with: locationProvider)
        }
    }

    let addStub = Stub<LocationConsumer, Void>()
    func add(_ consumer: LocationConsumer) {
        addStub.call(with: consumer)
    }

    let removeStub = Stub<LocationConsumer, Void>()
    func remove(_ consumer: LocationConsumer) {
        removeStub.call(with: consumer)
    }
}
