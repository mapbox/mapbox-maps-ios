#if os(OSX)
import AppKit
#else
import UIKit
#endif

internal protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool)

    func animationEnded(for gestureType: GestureType)
}

internal class GestureHandler: NSObject {
    internal let gestureRecognizer: GestureRecognizer

    internal weak var delegate: GestureHandlerDelegate?

    init(gestureRecognizer: GestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
    }

    deinit {
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }
}
