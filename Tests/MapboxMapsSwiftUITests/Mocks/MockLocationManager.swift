@_spi(Package) import MapboxMaps
@testable import MapboxMapsSwiftUI
import CoreLocation

final class MockLocationManager: LocationManaging {
    @Stubbed var options = LocationOptions()

    let addLocationConsumerStub = Stub<LocationConsumer, Void>()
    func addLocationConsumer(_ consumer: LocationConsumer) {
        addLocationConsumerStub.call(with: consumer)
    }

    let removeLocationConsumerStub = Stub<LocationConsumer, Void>()
    func removeLocationConsumer(_ consumer: LocationConsumer) {
        removeLocationConsumerStub.call(with: consumer)
    }

    let addPuckLocationConsumerStub = Stub<PuckLocationConsumer, Void>()
    func addPuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        addPuckLocationConsumerStub.call(with: consumer)
    }

    let removePuckLocationConsumerStub = Stub<PuckLocationConsumer, Void>()
    func removePuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        removePuckLocationConsumerStub.call(with: consumer)
    }

    // MARK: Simulate

    func simulateLocationUpdate(location: Location, isInterpolated: Bool = false) {
        addLocationConsumerStub.invocations.map(\.parameters).forEach { $0.locationUpdate(newLocation: location) }
        if isInterpolated {
            addPuckLocationConsumerStub.invocations.map(\.parameters).forEach { $0.puckLocationUpdate(newLocation: location) }
        }
    }
}
