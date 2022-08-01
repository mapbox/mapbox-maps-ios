import UIKit

/// This class is a wrapper view which forwards all touch events to its subviews
internal class SubviewInteractionOnlyView: UIView {

    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
