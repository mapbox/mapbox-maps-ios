import MapboxMaps

final class MockGestureManagerDelegate: GestureManagerDelegate {
    struct GestureParams {
        var gestureManager: GestureManager
        var gestureType: GestureType
    }

    let gestureDidBeginStub = Stub<GestureParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        let parameters = GestureParams(gestureManager: gestureManager, gestureType: gestureType)
        gestureDidBeginStub.call(with: parameters)
    }

    let gestureDidEndAnimatingStub = Stub<GestureParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        let parameters = GestureParams(gestureManager: gestureManager, gestureType: gestureType)
        gestureDidEndAnimatingStub.call(with: parameters)
    }

    struct GestureDidEndParams {
        var gestureManager: GestureManager
        var gestureType: GestureType
        var willAnimate: Bool
    }
    let gestureDidEndStub = Stub<GestureDidEndParams, Void>()
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        let parameters = GestureDidEndParams(gestureManager: gestureManager,
                                            gestureType: gestureType,
                                            willAnimate: willAnimate)
        gestureDidEndStub.call(with: parameters)
    }
}
