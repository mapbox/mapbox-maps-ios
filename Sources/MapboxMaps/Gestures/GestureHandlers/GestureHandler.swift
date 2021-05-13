import Foundation

internal class GestureHandler {

    /// The view that the gesture handler is operating on
    weak var view: UIView?

    /// The underlying gestureRecognizer that this handler is managing
    var gestureRecognizer: UIGestureRecognizer?

    /// The delegate that the gesture handler calls to manipulate the view
    weak var delegate: GestureHandlerDelegate!

    init(for view: UIView, withDelegate delegate: GestureHandlerDelegate) {
        self.view = view
        self.delegate = delegate
    }

    deinit {
        if let validGestureRecognizer = self.gestureRecognizer {
            self.view?.removeGestureRecognizer(validGestureRecognizer)
        }
    }
}
