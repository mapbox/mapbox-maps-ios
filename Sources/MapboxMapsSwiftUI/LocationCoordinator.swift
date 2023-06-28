import Foundation
@_spi(Package) import MapboxMaps

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

    private var locationManager: LocationManaging?

    func setup(with locationManager: LocationManaging) {
        guard self.locationManager == nil else { return }
        self.locationManager = locationManager
    }

    func update(deps: LocationDependencies) {
        if locationManager?.options != deps.locationOptions {
            locationManager?.options = deps.locationOptions
        }
    }
}
