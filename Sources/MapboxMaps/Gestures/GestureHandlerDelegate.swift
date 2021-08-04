import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {
    // The maps current camera state
    func cameraState() -> CameraState

    // View has been tapped with a number of taps and number of finger touches
    func tapped(numberOfTaps: Int, numberOfTouches: Int)

    func panBegan(at point: CGPoint)

    // View has been panned
    func panned(from startPoint: CGPoint, to: CGPoint)

    // Pan on the view has ended with a residual offset
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint)

    // Cancel any gesture transitions that are happening
    func cancelGestureTransitions()

    // Notifies conformer that a gesture has begun
    func gestureBegan(for gestureType: GestureType)

    // Returns initial scale of the map
    func scaleForZoom() -> CGFloat

    // Pinch has changed from the initial center/anchor
    func pinchChanged(withZoomIncrement zoomIncrement: CGFloat,
                      targetAnchor: CGPoint,
                      initialAnchor: CGPoint,
                      initialCameraState: CameraState)

    // Pinch has ended
    func pinchEnded()

    // Requests initial bearing of the map
    func rotationStartAngle() -> CGFloat

    // Bearing should change with `changedAngle` at a given `anchor`
    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat)

    // Rotation gesture is complete with a `finalAngle` and a given `anchor`
    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State)

    // Zoom changes based on new location of gesture
    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint)

    // Quick zoom gesture ended
    func quickZoomEnded()

    // Returns initial pitch of the map
    func initialPitch() -> CGFloat

    // Pitch gesture changed
    func pitchChanged(newPitch: CGFloat)

    // Pitch gesture ended
    func pitchEnded()

    // The tilt tolerance associated with the pitch gesture
    func horizontalPitchTiltTolerance() -> Double
}
