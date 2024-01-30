import CoreLocation
@testable import MapboxMaps

final class MockCLLocationManager: CLLocationManagerProtocol {
    @Stubbed var distanceFilter: CLLocationDistance = 0
    @Stubbed var desiredAccuracy: CLLocationAccuracy = 0
    @Stubbed var activityType: CLActivityType = .other

    var compatibleAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    var compatibleAccuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    @Stubbed var delegate: CLLocationManagerDelegate?

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

#if !(swift(>=5.9) && os(visionOS))
    var heading: CLHeading?

    @Stubbed var headingOrientation: CLDeviceOrientation = .unknown

    let startUpdatingHeadingStub = Stub<Void, Void>()
    func startUpdatingHeading() {
        startUpdatingHeadingStub.call()
    }

    let stopUpdatingHeadingStub = Stub<Void, Void>()
    func stopUpdatingHeading() {
        stopUpdatingHeadingStub.call()
    }
#endif
}
