import UIKit

internal protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool)

    func animationEnded(for gestureType: GestureType)
}

internal class GestureHandler: NSObject {
    internal let gestureRecognizer: UIGestureRecognizer

    internal let mapboxMap: MapboxMapProtocol

    internal let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal weak var delegate: GestureHandlerDelegate?

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
