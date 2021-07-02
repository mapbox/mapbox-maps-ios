import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {

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

    // Scale has changed with a new value and a given anchor
    func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint)

    // The center point of the pinch operation has moved from the previous position
    func pinchCenterMoved(offset: CGSize)

    // Pinch has completed with a final scale and possible drift
    func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint)

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
}

// Provides default implementation of GestureSupportableView methods.
internal extension GestureHandlerDelegate {

    func tapped(numberOfTaps: Int, numberOfTouches: Int) {}

    func panBegan(at point: CGPoint) {}

    // View has been panned
    func panned(from startPoint: CGPoint, to endPoint: CGPoint) {}

    // Pan on the view has ended (with a potential drift)
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) {}

    func cancelGestureTransitions() {}

    func gestureBegan(for gestureType: GestureType) {}

    func scaleForZoom() -> CGFloat { return 0.0 }

    func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint) {}

    func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {}

    func rotationStartAngle() -> CGFloat { return 0.0 }

    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {}

    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {}

    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {}

    func quickZoomEnded() {}

    func initialPitch() -> CGFloat { return 0.0 }

    func horizontalPitchTiltTolerance() -> Double { return 45.0 }

    func pitchChanged(newPitch: CGFloat) {}

    func pitchEnded() {}
}
