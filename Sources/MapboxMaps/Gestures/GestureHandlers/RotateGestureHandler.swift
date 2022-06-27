import UIKit

 /// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
 internal final class RotateGestureHandler: GestureHandler, UIGestureRecognizerDelegate {

     private var initialBearing: Double?

     private let mapboxMap: MapboxMapProtocol

     internal init(gestureRecognizer: UIRotationGestureRecognizer,
                   mapboxMap: MapboxMapProtocol) {
         self.mapboxMap = mapboxMap
         super.init(gestureRecognizer: gestureRecognizer)
         gestureRecognizer.delegate = self
         gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
     }

     internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                     shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         return self.gestureRecognizer === gestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer
     }

     func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
         let recognizer = (gestureRecognizer as! UIRotationGestureRecognizer)
         let speed = recognizer.velocity
         let rotation = recognizer.rotation.toDegrees()
         let deltaSinceStart = 0
         print("rrr velocity: \(speed), rotation: \(rotation)")
//         if (speed < 0.04 ||
//             speed > 0.07 && deltaSinceStart < 5 ||
//             speed > 0.15 && deltaSinceStart < 7 ||
//             speed > 0.5 && deltaSinceStart < 15) {
//             return false
//         }

         return true
     }

     @objc private func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
         guard let view = gestureRecognizer.view else {
             return
         }
         switch gestureRecognizer.state {
         case .began:
//             cameraAnimationsManager.cancelAnimations()
//             delegate?.gestureBegan(for: .rotate)
             initialBearing = mapboxMap.cameraState.bearing
         case .changed:
             guard let initialBearing = initialBearing else {
                 return
             }
             let rotationInDegrees = Double(gestureRecognizer.rotation * 180.0 / .pi * -1)
             print("rrr changed velocity: \(gestureRecognizer.velocity), rotation: \(rotationInDegrees)")
//             cameraAnimationsManager.cancelAnimations()
             let midpoint = gestureRecognizer.location(in: view)
             mapboxMap.setCamera(
                 to: CameraOptions(
                    anchor: midpoint,
                    bearing: (initialBearing + rotationInDegrees).truncatingRemainder(dividingBy: 360.0))
             )
         case .ended, .cancelled:
             initialBearing = nil
         default:
             break
         }
     }
 }
