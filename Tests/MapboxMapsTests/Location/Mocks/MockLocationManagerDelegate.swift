import MapboxMaps

final class MockLocationManagerDelegate: LocationPermissionsDelegate {
    struct DidChangeAccuracyAuthorizationParams {
        var locationManager: LocationManager
        var accuracyAuthorization: CLAccuracyAuthorization
    }
    let didChangeAccuracyAuthorizationStub = Stub<DidChangeAccuracyAuthorizationParams, Void>()
    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorizationStub.call(with: .init(
            locationManager: locationManager,
            accuracyAuthorization: accuracyAuthorization))
    }

    struct DidFailToLocateUserWithErrorParams {
        var locationManager: LocationManager
        var error: Error
    }
    let didFailToLocateUserWithErrorStub = Stub<DidFailToLocateUserWithErrorParams, Void>()
    func locationManager(_ locationManager: LocationManager, didFailToLocateUserWithError error: Error) {
        didFailToLocateUserWithErrorStub.call(with: .init(locationManager: locationManager, error: error))
    }

    let shouldDisplayHeadingCalibrationStub = Stub<LocationManager, Bool>(defaultReturnValue: false)
    func locationManagerShouldDisplayHeadingCalibration(_ locationManager: LocationManager) -> Bool {
        return shouldDisplayHeadingCalibrationStub.call(with: locationManager)
    }
}
