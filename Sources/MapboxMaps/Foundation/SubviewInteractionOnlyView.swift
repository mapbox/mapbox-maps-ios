#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// This class is a wrapper view which forwards all touch events to it's subviews
internal class SubviewInteractionOnlyView: UIView {

    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
