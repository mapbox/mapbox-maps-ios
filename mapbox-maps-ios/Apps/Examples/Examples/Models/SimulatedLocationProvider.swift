import MapboxMaps

final class SimulatedLocationProvider: LocationProvider {
    var locationProviderOptions = LocationOptions()

    let authorizationStatus = CLAuthorizationStatus.authorizedAlways

    let accuracyAuthorization = CLAccuracyAuthorization.fullAccuracy

    let heading: CLHeading? = nil

    var headingOrientation = CLDeviceOrientation.portrait

    private let currentLocation: CLLocation

    private weak var delegate: LocationProviderDelegate?

    init(currentLocation: CLLocation) {
        self.currentLocation = currentLocation
    }

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func startUpdatingLocation() {
        delegate?.locationProvider(self, didUpdateLocations: [currentLocation])
    }

    func requestAlwaysAuthorization() {
    }

    func requestWhenInUseAuthorization() {
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
    }

    func stopUpdatingLocation() {
    }

    func startUpdatingHeading() {
    }

    func stopUpdatingHeading() {
    }

    func dismissHeadingCalibrationDisplay() {
    }
}
