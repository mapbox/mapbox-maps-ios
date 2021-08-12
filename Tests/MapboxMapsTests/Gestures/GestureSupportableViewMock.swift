import UIKit
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl large_tuple
// Mock class that flags true when `GestureSupportableView` protocol methods have been called on it
class GestureHandlerDelegateMock: GestureHandlerDelegate {

    var coreCameraState = MapboxCoreMaps.CameraState(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                                     padding: EdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                     zoom: 10,
                                                     bearing: 0.0,
                                                     pitch: 0.0)

    var tapCalled = false
    var tapCalledWithNumberOfTaps = 0
    var tapCalledWithNumberOfTouches = 0

    var pannedCalled = false

    var pinchEndedMethod: (wasCalled: Bool, anchor: CGPoint?) = (false, nil)

    var cancelTransitionsCalled = false
    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    var rotationStartCalled = false
    var rotationChangedMethod: (wasCalled: Bool, newAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var rotationEndedMethod: (wasCalled: Bool, finalAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)

    var defaultPitch: CGFloat = 0.0
    var pitchTolerance = 45.0
    var pitchChangedMethod: (wasCalled: Bool, newPitch: CGFloat) = (false, 0.0)
    var pitchEndedMethod = false

    func cameraState() -> CameraState {
        return CameraState(coreCameraState)
    }

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

    struct PinchChangedParameters {
        var zoomIncrement: CGFloat
        var targetAnchor: CGPoint
        var initialAnchor: CGPoint
        var initialCameraState: CameraState
    }

    let pinchChangedStub = Stub<PinchChangedParameters, Void>()
    func pinchChanged(withZoomIncrement zoomIncrement: CGFloat,
                      targetAnchor: CGPoint,
                      initialAnchor: CGPoint,
                      initialCameraState: CameraState) {
        pinchChangedStub.call(with: .init(zoomIncrement: zoomIncrement,
                                          targetAnchor: targetAnchor,
                                          initialAnchor: initialAnchor,
                                          initialCameraState: cameraState()))
    }

    let pinchEndedStub = Stub<Void, Void>()
    func pinchEnded() {
        pinchEndedStub.call()
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

    func panBegan(at point: CGPoint) { }

    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) { }

    func initialPitch() -> CGFloat { return self.defaultPitch }

    func horizontalPitchTiltTolerance() -> Double { return pitchTolerance }
}
