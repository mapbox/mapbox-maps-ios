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

    var pinchChangedMethod: (wasCalled: Bool, newZoom: CGFloat?, anchor: CGPoint?, offset: CGSize?) = (false, nil, nil, nil)
    var pinchEndedMethod: (wasCalled: Bool, drift: Bool?, anchor: CGPoint?) = (false, nil, nil)

    var cancelTransitionsCalled = false
    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    var rotationStartCalled = false
    var rotationChangedMethod: (wasCalled: Bool, newAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var rotationEndedMethod: (wasCalled: Bool, finalAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)

    var initialPitch = 0.0
    var pitchTolerance = 45.0
    var pitchChangedMethod: (wasCalled: Bool, newPitch: CGFloat) = (false, 0.0)
    var pitchEndedMethod = false

    public func tapped(numberOfTaps: Int, numberOfTouches: Int) {
        tapCalled = true
        tapCalledWithNumberOfTaps = numberOfTaps
        tapCalledWithNumberOfTouches = numberOfTouches
    }

    public func panned(from startPoint: CGPoint, to endPoint: CGPoint) {
        pannedCalled = true
    }

    public func cancelGestureTransitions() {
        cancelTransitionsCalled = true
    }

    func gestureBegan(for gestureType: GestureType) {
        gestureBeganMethod.wasCalled = true
        gestureBeganMethod.type = gestureType
    }

    let scaleForZoomStub = Stub<Void, CGFloat>(defaultReturnValue: 0)
    func scaleForZoom() -> CGFloat {
        scaleForZoomStub.call()
    }

    func pinchChanged(with zoom: CGFloat, anchor: CGPoint, offset: CGSize) {
        pinchChangedMethod.wasCalled = true
        pinchChangedMethod.newZoom = zoom
        pinchChangedMethod.anchor = anchor
        pinchChangedMethod.offset = offset
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

    let quickZoomEndedStub = Stub<Void, Void>()
    func quickZoomEnded() {
        quickZoomEndedStub.call()
    }

    func pitchChanged(newPitch: CGFloat) {
        pitchChangedMethod.wasCalled = true
        pitchChangedMethod.newPitch = newPitch
    }

    func pitchEnded() {
        pitchEndedMethod = true
    }
}
