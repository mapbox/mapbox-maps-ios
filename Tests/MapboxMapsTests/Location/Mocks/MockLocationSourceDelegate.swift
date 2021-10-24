@testable import MapboxMaps

final class MockLocationSourceDelegate: LocationSourceDelegate {
    struct DidFailWithErrorParams {
        var locationSource: LocationSourceProtocol
        var error: Error
    }
    let didFailWithErrorStub = Stub<DidFailWithErrorParams, Void>()
    func locationSource(_ locationSource: LocationSourceProtocol,
                        didFailWithError error: Error) {
        didFailWithErrorStub.call(with: .init(
            locationSource: locationSource,
            error: error))
    }

    struct DidChangeAccuracyAuthorizationParams {
        var locationSource: LocationSourceProtocol
        var accuracyAuthorization: CLAccuracyAuthorization
    }
    let didChangeAccuracyAuthorizationStub = Stub<DidChangeAccuracyAuthorizationParams, Void>()
    func locationSource(_ locationSource: LocationSourceProtocol,
                        didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorizationStub.call(with: .init(
            locationSource: locationSource,
            accuracyAuthorization: accuracyAuthorization))
    }
}
