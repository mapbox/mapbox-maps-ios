import MapboxMaps

final class MockLocationManagerDelegate: AppleLocationProviderDelegate {
    struct DidChangeAccuracyAuthorizationParams {
        var locationProvider: AppleLocationProvider
        var accuracyAuthorization: CLAccuracyAuthorization
    }
    let didChangeAccuracyAuthorizationStub = Stub<DidChangeAccuracyAuthorizationParams, Void>()
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorizationStub.call(with: .init(
            locationProvider: locationProvider,
            accuracyAuthorization: accuracyAuthorization))
    }

    struct DidFailToLocateUserWithErrorParams {
        var locationProvider: AppleLocationProvider
        var error: Error
    }
    let didFailToLocateUserWithErrorStub = Stub<DidFailToLocateUserWithErrorParams, Void>()
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didFailWithError error: Error) {
        didFailToLocateUserWithErrorStub.call(with: .init(locationProvider: locationProvider, error: error))
    }

    let shouldDisplayHeadingCalibrationStub = Stub<AppleLocationProvider, Bool>(defaultReturnValue: false)
    func appleLocationProviderShouldDisplayHeadingCalibration(_ locationProvider: AppleLocationProvider) -> Bool {
        return shouldDisplayHeadingCalibrationStub.call(with: locationProvider)
    }
}
