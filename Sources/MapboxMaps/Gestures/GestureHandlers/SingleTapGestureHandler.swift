import UIKit

/// `SingleTapGestureHandler` manages a gesture recognizer looking for single tap touch events
internal final class SingleTapGestureHandler: GestureHandler {

    internal init(gestureRecognizer: UITapGestureRecognizer) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            delegate?.gestureBegan(for: .singleTap)
            delegate?.gestureEnded(for: .singleTap, willAnimate: false)
        default:
            break
        }
    }
}
