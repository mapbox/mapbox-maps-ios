import UIKit
import CoreLocation

@available(iOSApplicationExtension, unavailable)
extension MapView: OrnamentSupportableView {
    // User has tapped on an ornament
    internal func tapped() {

    }

    internal func compassTapped() {
        camera.cancelAnimations()

        var animator: BasicCameraAnimator?
        animator = camera.makeAnimator(duration: 0.3, curve: .easeOut, animations: { (transition) in
            transition.bearing.toValue = 0
        })

        animator?.addCompletion { (_) in
            animator = nil
        }

        animator?.startAnimation()
    }

    internal func subscribeCameraChangeHandler(_ handler: @escaping (CameraState) -> Void) {
        mapboxMap.onEvery(.cameraChanged) { [weak self] _ in
            guard let self = self else {
                return
            }
            handler(self.cameraState)
        }
    }
}

extension Style: LocationStyleProtocol { }
