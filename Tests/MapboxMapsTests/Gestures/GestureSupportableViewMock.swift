import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl large_tuple
// Mock class that flags true when `GestureSupportableView` protocol methods have been called on it
class GestureHandlerDelegateMock: GestureHandlerDelegate {

    var pinchEndedMethod: (wasCalled: Bool, anchor: CGPoint?) = (false, nil)

    var cancelTransitionsCalled = false
    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    var rotationStartCalled = false
    var rotationChangedMethod: (wasCalled: Bool, newAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var rotationEndedMethod: (wasCalled: Bool, finalAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)

    var pitchChangedMethod: (wasCalled: Bool, newPitch: CGFloat) = (false, 0.0)
    var pitchEndedMethod = false

    public func cancelGestureTransitions() {
        cancelTransitionsCalled = true
    }

    func gestureBegan(for gestureType: GestureType) {
        gestureBeganMethod.wasCalled = true
        gestureBeganMethod.type = gestureType
    }

    struct PinchChangedParameters {
        var zoomIncrement: CGFloat
        var targetAnchor: CGPoint
        var initialAnchor: CGPoint
        var initialCameraState: CameraState
    }

    func rotationStartAngle() -> CGFloat {
        rotationStartCalled = true
        return -1.0
    }

    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {
        rotationChangedMethod.wasCalled = true
        rotationChangedMethod.newAngle = changedAngle
        rotationChangedMethod.anchor = anchor
    }

    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        rotationEndedMethod.wasCalled = true
        rotationEndedMethod.finalAngle = finalAngle
        rotationEndedMethod.anchor = anchor
    }

    struct QuickZoomChangedParameters {
        var newScale: CGFloat
        var anchor: CGPoint
    }
    let quickZoomChangedStub = Stub<QuickZoomChangedParameters, Void>()
    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        quickZoomChangedStub.call(
            with: QuickZoomChangedParameters(newScale: newScale,
                                             anchor: anchor))
    }

    func pitchChanged(newPitch: CGFloat) {
        pitchChangedMethod.wasCalled = true
        pitchChangedMethod.newPitch = newPitch
    }

    func pitchEnded() {
        pitchEndedMethod = true
    }
}
