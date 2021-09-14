@testable import MapboxMaps

final class MockGestureHandlerDelegate: GestureHandlerDelegate {
    let gestureBeganStub = Stub<GestureType, Void>()
    func gestureBegan(for gestureType: GestureType) {
        gestureBeganStub.call(with: gestureType)
    }
}
