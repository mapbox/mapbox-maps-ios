import UIKit

/// This class is a wrapper view which forwards all touch events to it's subviews
public class SubviewInteractionOnlyView: UIView {

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
