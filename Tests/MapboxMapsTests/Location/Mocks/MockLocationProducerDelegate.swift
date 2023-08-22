@testable import MapboxMaps

final class MockLocationProducerDelegate: AppleLocationProviderDelegate {
    struct DidFailWithErrorParams {
        var locationProvider: AppleLocationProvider
        var error: Error
    }
    let didFailWithErrorStub = Stub<DidFailWithErrorParams, Void>()
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didFailWithError error: Error) {
        didFailWithErrorStub.call(with: .init(
            locationProvider: locationProvider,
            error: error))
    }

    struct DidChangeAccuracyAuthorizationParams {
        var locationProvider: AppleLocationProvider
        var accuracyAuthorization: CLAccuracyAuthorization
    }
    let didChangeAccuracyAuthorizationStub = Stub<DidChangeAccuracyAuthorizationParams, Void>()
    func appleLocationProvider(_ locationProvider: AppleLocationProvider,
                               didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorizationStub.call(with: .init(
            locationProvider: locationProvider,
            accuracyAuthorization: accuracyAuthorization))
    }

    let shouldDisplayHeadingCalibrationStub = Stub<AppleLocationProvider, Bool>(defaultReturnValue: false)
    func appleLocationProviderShouldDisplayHeadingCalibration(_ locationProvider: AppleLocationProvider) -> Bool {
        return shouldDisplayHeadingCalibrationStub.call(with: locationProvider)
    }
}
