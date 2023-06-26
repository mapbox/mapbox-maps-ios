import Foundation
import MapboxMaps

final class OnDemandLocationProvider: LocationProvider {
    private let locationConsumers = NSHashTable<AnyObject>.weakObjects()


    var latestLocation: Location? {
        return Location(
            location: CLLocation(latitude: currentCoordination.latitude, longitude: currentCoordination.longitude),
            accuracyAuthorization: .fullAccuracy
        )
    }

    var currentCoordination: LocationCoordinate2D! {
        didSet {
            startUpdatingLocation()
        }
    }

    init() {}

    func startUpdatingLocation() {
        guard currentCoordination != nil else { return }
        let clLocation = CLLocation(latitude: currentCoordination.latitude, longitude: currentCoordination.longitude)
        let location = Location(location: clLocation, accuracyAuthorization: .fullAccuracy)

        for consumer in locationConsumers.allObjects {
            (consumer as? LocationConsumer)?.locationUpdate(newLocation: location)
        }
    }

    func add(consumer: LocationConsumer) {
        locationConsumers.add(consumer)
    }

    func remove(consumer: LocationConsumer) {
        locationConsumers.remove(consumer)
    }
}
