import CoreLocation
import MapboxMaps

final class MockLocationProvider: LocationProvider {

    var locationProviderOptions = LocationOptions()

    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var accuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    var heading: CLHeading?

    var headingOrientation: CLDeviceOrientation = .unknown

    let setDelegateStub = Stub<LocationProviderDelegate, Void>()
    func setDelegate(_ delegate: LocationProviderDelegate) {
        setDelegateStub.call(with: delegate)
    }

    let requestAlwaysAuthorizationStub = Stub<Void, Void>()
    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationStub.call()
    }

    let requestWhenInUseAuthorizationStub = Stub<Void, Void>()
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationStub.call()
    }

    let requestTemporaryFullAccuracyAuthorizationStub = Stub<String, Void>()
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        requestTemporaryFullAccuracyAuthorizationStub.call(with: purposeKey)
    }

    let startUpdatingLocationStub = Stub<Void, Void>()
    func startUpdatingLocation() {
        startUpdatingLocationStub.call()
    }

    let stopUpdatingLocationStub = Stub<Void, Void>()
    func stopUpdatingLocation() {
        stopUpdatingLocationStub.call()
    }

    let startUpdatingHeadingStub = Stub<Void, Void>()
    func startUpdatingHeading() {
        startUpdatingHeadingStub.call()
    }

    let stopUpdatingHeadingStub = Stub<Void, Void>()
    func stopUpdatingHeading() {
        stopUpdatingHeadingStub.call()
    }

    let dismissHeadingCalibrationDisplayStub = Stub<Void, Void>()
    func dismissHeadingCalibrationDisplay() {
        dismissHeadingCalibrationDisplayStub.call()
    }
}
