import CoreLocation

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
#endif

class LocationProviderMock: LocationProvider {
    var locationProviderOptions: LocationOptions

    var authorizationStatus: CLAuthorizationStatus

    var accuracyAuthorization: CLAccuracyAuthorization

    var heading: CLHeading?

    var headingOrientation: CLDeviceOrientation

    private weak var delegate: LocationProviderDelegate?

    init(options: LocationOptions) {
        self.locationProviderOptions = options
        self.authorizationStatus = .notDetermined
        self.accuracyAuthorization = .fullAccuracy
        self.headingOrientation = .unknown
    }

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {
        self.authorizationStatus = .authorizedAlways
    }

    func requestWhenInUseAuthorization() {
        self.authorizationStatus = .authorizedWhenInUse
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        self.accuracyAuthorization = .fullAccuracy
    }

    func startUpdatingLocation() {
        print("Set location to ...")
    }

    func stopUpdatingLocation() {
        print("Stopped updating location")
    }

    func startUpdatingHeading() {
        print("Set heading to ...")
    }

    func stopUpdatingHeading() {
        print("Stopped updating heading")
    }

    func dismissHeadingCalibrationDisplay() {
        print("Dismissed heading calibration display")
    }
}
