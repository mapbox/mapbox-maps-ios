import Foundation

protocol LocationManaging {
    var options: LocationOptions { get set }
}

extension LocationManager: LocationManaging {}

@available(iOS 13.0, *)
struct LocationDependencies {
    var locationOptions = LocationOptions()
}

@available(iOS 13.0, *)
final class LocationCoordinator {

    private var locationManager: LocationManaging

    init(locationManager: LocationManaging) {
        self.locationManager = locationManager
    }

    func update(deps: LocationDependencies) {
        if locationManager.options != deps.locationOptions {
            locationManager.options = deps.locationOptions
        }
    }
}
