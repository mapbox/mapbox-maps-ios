import UIKit

internal protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)
}

internal class GestureHandler<T>: NSObject where T: UIGestureRecognizer {
    internal let gestureRecognizer: T

    internal let mapboxMap: MapboxMapProtocol

    internal let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal weak var delegate: GestureHandlerDelegate?

    init(gestureRecognizer: T,
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
