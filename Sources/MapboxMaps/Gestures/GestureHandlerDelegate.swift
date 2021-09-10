import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {
    // Cancel any gesture transitions that are happening
    func cancelGestureTransitions()

    // Notifies conformer that a gesture has begun
    func gestureBegan(for gestureType: GestureType)

    // Requests initial bearing of the map
    func rotationStartAngle() -> CGFloat

    // Bearing should change with `changedAngle` at a given `anchor`
    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat)

    // Rotation gesture is complete with a `finalAngle` and a given `anchor`
    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State)

    // Zoom changes based on new location of gesture
    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint)

    // Pitch gesture changed
    func pitchChanged(newPitch: CGFloat)

    // Pitch gesture ended
    func pitchEnded()

    // The tilt tolerance associated with the pitch gesture
    func horizontalPitchTiltTolerance() -> Double
}
