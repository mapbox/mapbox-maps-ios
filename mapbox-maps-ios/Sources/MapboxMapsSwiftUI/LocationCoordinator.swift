import Foundation
@_spi(Package) import MapboxMaps

protocol LocationManaging {
    var options: LocationOptions { get set }
    func addLocationConsumer(_ consumer: LocationConsumer)
    func removeLocationConsumer(_ : LocationConsumer)
    func addPuckLocationConsumer(_ consumer: PuckLocationConsumer)
    func removePuckLocationConsumer(_ consumer: PuckLocationConsumer)
}

extension LocationManager: LocationManaging {}

@available(iOS 13.0, *)
struct LocationDependencies {
    var locationOptions = LocationOptions()
    var locationUpdateHandlers: [LocationUpdateAction] = []
    var puckLocationUpdateHandlers: [LocationUpdateAction] = []
}

@available(iOS 13.0, *)
final class LocationCoordinator {

    private var locationManager: LocationManaging?
    private var locationUpdateHandlers: [LocationUpdateAction] = []
    private var puckLocationUpdateHandlers: [LocationUpdateAction] = []

    private var subscribeToLocationUpdates = Once()
    private var subscribeToPuckLocationUpdates = Once()

    deinit {
        locationManager?.removeLocationConsumer(self)
        locationManager?.removePuckLocationConsumer(self)
    }

    func setup(with locationManager: LocationManaging) {
        guard self.locationManager == nil else { return }
        self.locationManager = locationManager
    }

    func update(deps: LocationDependencies) {
        if locationManager?.options != deps.locationOptions {
            locationManager?.options = deps.locationOptions
        }

        locationUpdateHandlers = deps.locationUpdateHandlers
        puckLocationUpdateHandlers = deps.puckLocationUpdateHandlers

        if !locationUpdateHandlers.isEmpty {
            subscribeToLocationUpdates {
                locationManager?.addLocationConsumer(_: self)
            }
        } else {
            locationManager?.removeLocationConsumer(_: self)
            subscribeToLocationUpdates.reset()
        }

        if !puckLocationUpdateHandlers.isEmpty {
            subscribeToPuckLocationUpdates {
                locationManager?.addPuckLocationConsumer(self)
            }
        } else {
            locationManager?.removePuckLocationConsumer(self)
            subscribeToPuckLocationUpdates.reset()
        }
    }
}

@available(iOS 13.0, *)
extension LocationCoordinator: LocationConsumer, PuckLocationConsumer {

    func locationUpdate(newLocation: Location) {
        for handler in locationUpdateHandlers {
            handler(newLocation)
        }
    }

    func puckLocationUpdate(newLocation: Location) {
        for handler in puckLocationUpdateHandlers {
            handler(newLocation)
        }
    }
}
