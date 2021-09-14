import UIKit

/// `PitchGestureHandler` updates the map camera in response to a vertical,
/// 2-touch pan gesture in which the angle between the touch points is less than 45°.
internal class PitchGestureHandler: GestureHandler<UIPanGestureRecognizer>, UIGestureRecognizerDelegate {
    private let maximumAngleBetweenTouchPoints: CGFloat = 45

    private var initialPitch: CGFloat?

    internal init(view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.minimumNumberOfTouches = 2
        panGestureRecognizer.maximumNumberOfTouches = 2
        view.addGestureRecognizer(panGestureRecognizer)
        super.init(
            gestureRecognizer: panGestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePitchGesture(_:)))
    }

    private func touchAngleIsLessThanMaximum(for gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view,
              let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
              gestureRecognizer.minimumNumberOfTouches == 2 else {
            return false
        }
        let touchLocation0 = gestureRecognizer.location(ofTouch: 0, in: view)
        let touchLocation1 = gestureRecognizer.location(ofTouch: 1, in: view)
        let angleBetweenTouchLocations = angleOfLine(from: touchLocation0, to: touchLocation1)
        return abs(angleBetweenTouchLocations) < maximumAngleBetweenTouchPoints
    }

    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return touchAngleIsLessThanMaximum(for: gestureRecognizer)
    }

    @objc internal func handlePitchGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.numberOfTouches == 2 else {
            return
        }
        switch gestureRecognizer.state {
        case .began:
            initialPitch = mapboxMap.cameraState.pitch
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pitch)
        case .changed:
            guard let view = gestureRecognizer.view,
                  let initialPitch = initialPitch else {
                return
            }

            let translation = gestureRecognizer.translation(in: view)
            let translationAngle = angleOfLine(from: .zero, to: translation)

            // If the angle between the touch locations is less than the maximum
            // AND the translation angle is more than 60 degrees, update the pitch.
            if touchAngleIsLessThanMaximum(for: gestureRecognizer), abs(translationAngle) > 60 {
                let verticalGestureTranslation = translation.y
                let slowDown = CGFloat(2.0)
                let newPitch = initialPitch - (verticalGestureTranslation / slowDown)
                mapboxMap.setCamera(to: CameraOptions(pitch: newPitch))
            }
        case .ended, .cancelled:
            initialPitch = nil
        default:
            break
        }
    }

    private func angleOfLine(from start: CGPoint, to end: CGPoint) -> CGFloat {
        var origin = start
        var end = end
        if start.x > end.x {
            origin = end
            end = start
        }
        let deltaX = end.x - origin.x
        let deltaY = end.y - origin.y
        let angleInRadians = atan2(deltaY, deltaX)
        return angleInRadians * 180 / .pi
    }
}
