@testable import MapboxMaps

final class MockGestureHandlerDelegate: GestureHandlerDelegate {

    var decelerationRate: CGFloat = 0

    var panScrollingMode: PanScrollingMode = .horizontalAndVertical

    let gestureBeganStub = Stub<GestureType, Void>()
    func gestureBegan(for gestureType: GestureType) {
        gestureBeganStub.call(with: gestureType)
    }
}
