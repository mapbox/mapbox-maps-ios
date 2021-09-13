import UIKit

/// `PitchGestureHandler` updates the map camera in response to a vertical,
/// 2-touch pan gesture in which the angle between the touch points is less than 45°.
internal class PitchGestureHandler: GestureHandler {
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
        panGestureRecognizer.addTarget(self, action: #selector(handlePitchGesture(_:)))
    }

    @objc internal func handlePitchGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer.numberOfTouches == 2 else {
            return
        }
        switch panGestureRecognizer.state {
        case .began:
            initialPitch = mapboxMap.cameraState.pitch
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pitch)
        case .changed:
            guard let view = panGestureRecognizer.view,
                  let initialPitch = initialPitch else {
                return
            }
            let touchLocation0 = panGestureRecognizer.location(ofTouch: 0, in: view)
            let touchLocation1 = panGestureRecognizer.location(ofTouch: 1, in: view)
            let angleBetweenTouchLocations = GestureUtilities.angleBetweenPoints(touchLocation0, touchLocation1)

            let translation = panGestureRecognizer.translation(in: view)
            let translationAngle = GestureUtilities.angleBetweenPoints(.zero, translation)

            // If the angle between the touch locations is less than 45 degrees
            // AND the translation angle is more than 60 degrees, update the pitch.
            if fabs(angleBetweenTouchLocations) < 45, fabs(translationAngle) > 60 {
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
}
