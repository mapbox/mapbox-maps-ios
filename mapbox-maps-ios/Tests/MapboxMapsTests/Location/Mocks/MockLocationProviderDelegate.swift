import MapboxMaps

final class MockLocationProviderDelegate: LocationProviderDelegate {
    struct DidUpdateLocationsParams {
        var provider: LocationProvider
        var locations: [CLLocation]
    }
    let didUpdateLocationsStub = Stub<DidUpdateLocationsParams, Void>()
    func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocationsStub.call(with: .init(provider: provider, locations: locations))
    }

    struct DidUpdateHeadingParams {
        var provider: LocationProvider
        var newHeading: CLHeading
    }
    let didUpdateHeadingStub = Stub<DidUpdateHeadingParams, Void>()
    func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeadingStub.call(with: .init(provider: provider, newHeading: newHeading))
    }

    struct DidFailWithErrorParams {
        var provider: LocationProvider
        var error: Error
    }
    let didFailWithErrorStub = Stub<DidFailWithErrorParams, Void>()
    func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        didFailWithErrorStub.call(with: .init(provider: provider, error: error))
    }

    let didChangeAuthorizationStub = Stub<LocationProvider, Void>()
    func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        didChangeAuthorizationStub.call(with: provider)
    }
}
