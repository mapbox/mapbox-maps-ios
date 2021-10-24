@testable import MapboxMaps

final class MockLocationSource: LocationSourceProtocol {
    weak var delegate: LocationSourceDelegate?

    var latestLocation: Location?

    var consumers = NSHashTable<LocationConsumer>.weakObjects()

    var locationProvider: LocationProvider = MockLocationProvider()

    let addStub = Stub<LocationConsumer, Void>()
    func add(_ consumer: LocationConsumer) {
        addStub.call(with: consumer)
    }

    let removeStub = Stub<LocationConsumer, Void>()
    func remove(_ consumer: LocationConsumer) {
        removeStub.call(with: consumer)
    }

    let updateHeadingForCurrentDeviceOrientationStub = Stub<Void, Void>()
    func updateHeadingForCurrentDeviceOrientation() {
        updateHeadingForCurrentDeviceOrientationStub.call()
    }
}
