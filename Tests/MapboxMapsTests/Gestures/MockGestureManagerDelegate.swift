import MapboxMaps

final class MockGestureManagerDelegate: GestureManagerDelegate {
    let gestureBeganStub = Stub<GestureType, Void>()
    func gestureBegan(for gestureType: GestureType) {
        gestureBeganStub.call(with: gestureType)
    }
}
