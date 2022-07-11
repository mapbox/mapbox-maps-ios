import UIKit
import CoreLocation

internal protocol RotateGestureHandlerProtocol: FocusableGestureHandlerProtocol {
    var simultaneousRotateAndPinchZoomEnabled: Bool { get set }
}

 /// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
 internal final class RotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
     internal var simultaneousRotateAndPinchZoomEnabled: Bool = true
     internal var focalPoint: CGPoint?

     private let mapboxMap: MapboxMapProtocol

     private var initialBearing: CLLocationDirection?
     var isMapRotating = false
     private var discardedRotationAngle: CGFloat = 0

     internal init(gestureRecognizer: UIRotationGestureRecognizer, mapboxMap: MapboxMapProtocol) {
         self.mapboxMap = mapboxMap
         super.init(gestureRecognizer: gestureRecognizer)
         gestureRecognizer.delegate = self
         gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
     }

     @objc private func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
         guard let view = gestureRecognizer.view else {
             return
         }
         let velocity = gestureRecognizer.velocity
         switch (gestureRecognizer.state, isMapRotating) {
         case (.began, _):
             discardedRotationAngle += abs(gestureRecognizer.rotation)
             gestureRecognizer.rotation = 0
             self.initialBearing = mapboxMap.cameraState.bearing
             print("rrr rotation detected mapBearing: \(self.initialBearing) rotation \(discardedRotationAngle.toDegrees())")
         case (.changed, false):
             guard shouldStartRotating(with: gestureRecognizer.velocity, deltaSinceStart: discardedRotationAngle + abs(gestureRecognizer.rotation)) else {
                 discardedRotationAngle += abs(gestureRecognizer.rotation)
                 gestureRecognizer.rotation = 0
                 print("rrr rotation discarded angle \(discardedRotationAngle.toDegrees()), velocity \(velocity)")
                 return
             }

             print("rrr rotation started mapBearing \(initialBearing)")
             isMapRotating = true
             // pretend to be pinch gesture for backwards compatibility
             delegate?.gestureBegan(for: .pinch)
             fallthrough
         case (.changed, true):
             guard let initialBearing = initialBearing else {
                 return
             }
             foo()
         case (.cancelled, _), (.ended, _):
             if isMapRotating {
                 delegate?.gestureEnded(for: .pinch, willAnimate: false)
             }
             print("rrr rotation finished")
             isMapRotating = false
             discardedRotationAngle = 0
         default:
             break
         }
     }

     private var rotated = true
     func scheduleRotationUpdate() {
         guard isMapRotating else {
             return
         }
         rotated = false
         DispatchQueue.main.async {
             if self.rotated {
                 return
             }

             print("rrr ----->>> async went through")
             self.foo()
         }
     }

     func foo() {
         rotated = true
         // flip the sign since the UIKit coordinate system is flipped
          // relative to the coordinate system used for bearing.
         let gestureRecognizer = self.gestureRecognizer as! UIRotationGestureRecognizer
         let rotationInDegrees = -CLLocationDirection(gestureRecognizer.rotation.toDegrees())
         let midpoint = gestureRecognizer.location(in: gestureRecognizer.view)
         let bearing = (initialBearing! + rotationInDegrees).truncatingRemainder(dividingBy: 360.0)
         print("rrr rotating the map by \(rotationInDegrees)\t to bearing \(bearing)")

         mapboxMap.setCamera(
             to: CameraOptions(
                anchor: focalPoint ?? midpoint,
                bearing: bearing)
         )

     }

     private func shouldStartRotating(with velocity: CGFloat, deltaSinceStart: CGFloat) -> Bool {
         return true
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
