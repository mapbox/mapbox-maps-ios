import MapboxMaps

final class MockGestureManagerDelegate: GestureManagerDelegate {
    struct GestureParams {
        var gestureManager: GestureManager
        var gestureType: GestureType
    }

    let gestureBeganStub = Stub<GestureParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        let parameters = GestureParams(gestureManager: gestureManager, gestureType: gestureType)
        gestureBeganStub.call(with: parameters)
    }

    let driftEndedStub = Stub<GestureParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didEndDeceleratingFor gestureType: GestureType) {
        let parameters = GestureParams(gestureManager: gestureManager, gestureType: gestureType)
        driftEndedStub.call(with: parameters)
    }

    struct GestureEndedParams {
        var gestureManager: GestureManager
        var gestureType: GestureType
        var willDecelerate: Bool
    }
    let gestureEndedStub = Stub<GestureEndedParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willDecelerate: Bool) {
        let parameters = GestureEndedParams(gestureManager: gestureManager,
                                            gestureType: gestureType,
                                            willDecelerate: willDecelerate)
        gestureEndedStub.call(with: parameters)
    }
}
