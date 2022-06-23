import Foundation
import MapboxMaps

final class OnDemandLocationProvider: LocationProvider {
    var locationProviderOptions = LocationOptions()
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var accuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    var heading: CLHeading?
    var headingOrientation: CLDeviceOrientation = .portrait

    private weak var delegate: LocationProviderDelegate?

    var currentCoordination: LocationCoordinate2D! {
        didSet {
            startUpdatingLocation()
        }
    }

    init() {}

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {}
    func requestWhenInUseAuthorization() {}
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {}

    func startUpdatingLocation() {
        guard currentCoordination != nil else { return }
        delegate?.locationProvider(
            self,
            didUpdateLocations: [CLLocation(latitude: currentCoordination.latitude, longitude: currentCoordination.longitude)]
        )
    }

    func stopUpdatingLocation() {}

    func startUpdatingHeading() {}
    func stopUpdatingHeading() {}
    func dismissHeadingCalibrationDisplay() {}
}
