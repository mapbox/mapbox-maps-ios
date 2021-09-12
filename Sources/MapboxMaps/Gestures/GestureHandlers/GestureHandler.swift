import Foundation

internal class GestureHandler {

    /// The view that the gesture handler is operating on
    weak var view: UIView?
    internal weak var delegate: GestureManagerDelegate?

    /// The underlying gestureRecognizer that this handler is managing
    var gestureRecognizer: UIGestureRecognizer?

    init(for view: UIView) {
        self.view = view
    }

    deinit {
        if let validGestureRecognizer = self.gestureRecognizer {
            self.view?.removeGestureRecognizer(validGestureRecognizer)
        }
    }
}
