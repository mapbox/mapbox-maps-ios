import UIKit

protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool)

    func animationEnded(for gestureType: GestureType)
}

class GestureHandler: NSObject {
    let gestureRecognizer: UIGestureRecognizer

    weak var delegate: GestureHandlerDelegate?

    init(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
    }

    deinit {
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }
}
