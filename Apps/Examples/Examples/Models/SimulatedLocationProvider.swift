import MapboxMaps

final class SimulatedLocationProvider: LocationProvider {
    var latestLocation: Location? {
        Location(location: currentLocation, accuracyAuthorization: .fullAccuracy)
    }
    private let currentLocation: CLLocation

    init(currentLocation: CLLocation) {
        self.currentLocation = currentLocation
    }

    func add(consumer: LocationConsumer) {
        consumer.locationUpdate(newLocation: Location(location: currentLocation, accuracyAuthorization: .fullAccuracy))
    }

    func remove(consumer: LocationConsumer) {

    }
}
