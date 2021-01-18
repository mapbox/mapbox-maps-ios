import UIKit
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl large_tuple
// Mock class that flags true when `GestureSupportableView` protocol methods have been called on it
class GestureHandlerDelegateMock: GestureHandlerDelegate {

    var tapCalled = false
    var tapCalledWithNumberOfTaps = 0
    var tapCalledWithNumberOfTouches = 0

    var pannedCalled = false

    var scaleForZoomCalled = false
    var pinchScaleChangedMethod: (wasCalled: Bool, newScale: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var pinchEndedMethod: (wasCalled: Bool, drift: Bool?, anchor: CGPoint?) = (false, nil, nil)

    var cancelTransitionsCalled = false
    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    var rotationStartCalled = false
    var rotationChangedMethod: (wasCalled: Bool, newAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var rotationEndedMethod: (wasCalled: Bool, finalAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)

    var quickZoomCalled = false
    var quickZoomChangedMethod: (wasCalled: Bool, newScale: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var quickZoomEndedMethod = false

    var initialPitch = 0.0
    var pitchTolerance = 45.0
    var pitchChangedMethod: (wasCalled: Bool, newPitch: CGFloat) = (false, 0.0)
    var pitchEndedMethod = false

    public func tapped(numberOfTaps: Int, numberOfTouches: Int) {
        tapCalled = true
        tapCalledWithNumberOfTaps = numberOfTaps
        tapCalledWithNumberOfTouches = numberOfTouches
    }

    public func panned(by displacement: CGPoint) {
        pannedCalled = true
    }

    public func cancelGestureTransitions() {
        cancelTransitionsCalled = true
    }

    func gestureBegan(for gestureType: GestureType) {
        gestureBeganMethod.wasCalled = true
        gestureBeganMethod.type = gestureType
    }

    func scaleForZoom() -> CGFloat {
        scaleForZoomCalled = true
        return -1.0
    }

    func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint) {
        pinchScaleChangedMethod.wasCalled = true
        pinchScaleChangedMethod.newScale = newScale
        pinchScaleChangedMethod.anchor = anchor
    }

    func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {
        pinchEndedMethod.wasCalled = true
        pinchEndedMethod.drift = possibleDrift
        pinchEndedMethod.anchor = anchor
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

    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        quickZoomChangedMethod.wasCalled = true
        quickZoomChangedMethod.newScale = newScale
        quickZoomChangedMethod.anchor = anchor
    }

    func quickZoomEnded() {
        quickZoomCalled = true
        quickZoomEndedMethod = true
    }

    func pitchChanged(newPitch: CGFloat) {
        pitchChangedMethod.wasCalled = true
        pitchChangedMethod.newPitch = newPitch
    }

    func pitchEnded() {
        pitchEndedMethod = true
    }
}
