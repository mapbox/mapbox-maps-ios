import UIKit
import CoreLocation

internal protocol RotateGestureHandlerProtocol: FocusableGestureHandlerProtocol {
    var simultaneousRotateAndPinchZoomEnabled: Bool { get set }
    func scheduleRotationUpdateIfNeeded()
}

 /// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
 internal final class RotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
     internal var simultaneousRotateAndPinchZoomEnabled: Bool = true
     internal var focalPoint: CGPoint?

     private let mapboxMap: MapboxMapProtocol

     private var initialBearing: CLLocationDirection
     private var isMapRotating = false
     private var discardedRotationAngle: CGFloat = 0

     private var rotateGestureRecognizer: UIRotationGestureRecognizer

     internal init(gestureRecognizer: UIRotationGestureRecognizer, mapboxMap: MapboxMapProtocol) {
         self.mapboxMap = mapboxMap
         self.rotateGestureRecognizer = gestureRecognizer
         self.initialBearing = mapboxMap.cameraState.bearing
         super.init(gestureRecognizer: gestureRecognizer)
         gestureRecognizer.delegate = self
         gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
     }

     @objc private func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
         switch (gestureRecognizer.state, isMapRotating) {
         case (.began, _):
             discardedRotationAngle += abs(gestureRecognizer.rotation)
             gestureRecognizer.rotation = 0
             self.initialBearing = mapboxMap.cameraState.bearing
         case (.changed, false):
             guard shouldStartRotating(with: gestureRecognizer.velocity, deltaSinceStart: discardedRotationAngle + abs(gestureRecognizer.rotation)) else {
                 discardedRotationAngle += abs(gestureRecognizer.rotation)
                 gestureRecognizer.rotation = 0
                 return
             }

             isMapRotating = true
             // pretend to be pinch gesture for backwards compatibility
             delegate?.gestureBegan(for: .pinch)
             fallthrough
         case (.changed, true):
             updateBearing()
         case (.cancelled, _), (.ended, _):
             if isMapRotating {
                 delegate?.gestureEnded(for: .pinch, willAnimate: false)
             }
             isMapRotating = false
             discardedRotationAngle = 0
         default:
             break
         }
     }

     private var rotationUpdateNeeded = false

     /// Appends bearing update to the end of the main queue.
     /// The update will be performed only if no other bearing update precedes it.
     func scheduleRotationUpdateIfNeeded() {
         guard isMapRotating else {
             return
         }
         rotationUpdateNeeded = true
         DispatchQueue.main.async {
             guard self.rotationUpdateNeeded else {
                 return
             }

             self.updateBearing()
         }
     }

     private func updateBearing() {
         guard let view = gestureRecognizer.view else {
             return
         }

         rotationUpdateNeeded = false

         // flip the sign since the UIKit coordinate system is flipped
          // relative to the coordinate system used for bearing.
         let rotationInDegrees = -CLLocationDirection(rotateGestureRecognizer.rotation.toDegrees())
         let midpoint = gestureRecognizer.location(in: view)
         let bearing = (initialBearing + rotationInDegrees).wrapped(to: 0..<360)

         mapboxMap.setCamera(to: CameraOptions(anchor: focalPoint ?? midpoint, bearing: bearing))
     }

     private func shouldStartRotating(with velocity: CGFloat, deltaSinceStart: CGFloat) -> Bool {
         let deltaSinceStartInDegrees = deltaSinceStart.toDegrees()
         let velocityInDegreesPerMillisecond = abs(velocity).toDegrees() / 1000.0

         let lowVelocity = velocityInDegreesPerMillisecond < 0.04 ||
         velocityInDegreesPerMillisecond > 0.07 && deltaSinceStartInDegrees < 5 ||
         velocityInDegreesPerMillisecond > 0.15 && deltaSinceStartInDegrees < 7 ||
         velocityInDegreesPerMillisecond > 0.5 && deltaSinceStartInDegrees < 15
         let notEnoughRotation = deltaSinceStartInDegrees < 3

         return !lowVelocity && !notEnoughRotation
     }
 }

extension RotateGestureHandler: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureRecognizer === gestureRecognizer &&
        otherGestureRecognizer is UIPinchGestureRecognizer &&
        simultaneousRotateAndPinchZoomEnabled
    }
}
