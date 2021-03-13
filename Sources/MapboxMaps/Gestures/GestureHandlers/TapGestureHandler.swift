import UIKit

/// The TapGestureHandler is responsible for all `tap`
/// related infrastructure and tells the view to update itself when required
internal class TapGestureHandler: GestureHandler {

    // Configures the TapGestureRecognizer to handle a tap
    public required init(for view: UIView,
                         numberOfTapsRequired numberOfTaps: Int = 1,
                         numberOfTouchesRequired: Int = 1,
                         withDelegate delegate: GestureHandlerDelegate) {

        super.init(for: view, withDelegate: delegate)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = numberOfTaps
        tapGestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        view.addGestureRecognizer(tapGestureRecognizer)
        gestureRecognizer = tapGestureRecognizer
    }

    // Calls view to process the tap gesture
    @objc internal func handleTap(_ tap: UITapGestureRecognizer) {
        delegate.tapped(numberOfTaps: tap.numberOfTapsRequired, numberOfTouches: tap.numberOfTouchesRequired)
    }
}
