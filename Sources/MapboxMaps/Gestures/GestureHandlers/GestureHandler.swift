import UIKit

internal class GestureHandler {
    internal let gestureRecognizer: UIGestureRecognizer

    internal let mapboxMap: MapboxMapProtocol

    internal let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal weak var delegate: GestureManagerDelegate?

    init(gestureRecognizer: UIGestureRecognizer,
         mapboxMap: MapboxMapProtocol,
         cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.gestureRecognizer = gestureRecognizer
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
    }

    deinit {
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }
}
