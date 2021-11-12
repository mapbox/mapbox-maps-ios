import MapboxMaps

final class MockLocationConsumer: LocationConsumer {
    let locationUpdateStub = Stub<Location, Void>()
    func locationUpdate(newLocation: Location) {
        locationUpdateStub.call(with: newLocation)
    }
}
