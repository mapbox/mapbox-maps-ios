#if os(OSX)
import AppKit
#else
import UIKit
#endif

/// This class is a wrapper view which forwards all touch events to its subviews
internal class SubviewInteractionOnlyView: View {

    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> View? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
