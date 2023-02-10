import UIKit

internal protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool)

    func animationEnded(for gestureType: GestureType)
}

internal class GestureHandler: NSObject {
    internal let gestureRecognizer: UIGestureRecognizer

    internal weak var delegate: GestureHandlerDelegate?

    init(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
    }

    deinit {
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }
}
