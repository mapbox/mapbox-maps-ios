import UIKit

final class ViewAnnotationsContainer: UIView {
    var subviewDebugFrames: Bool = false {
        didSet {
            if subviewDebugFrames != oldValue {
                subviews.forEach(toggleDebugBorder)
            }
        }
    }

    /// Forwards all touch events to its subviews
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        toggleDebugBorder(subview)
    }

    func toggleDebugBorder(_ subview: UIView) {
        if subviewDebugFrames {
            let debugFrame = UIView(frame: subview.bounds)
            debugFrame.layer.borderWidth = 1.0
            debugFrame.layer.borderColor = UIColor.red.withAlphaComponent(0.6).cgColor
            debugFrame.isUserInteractionEnabled = false
            debugFrame.tag = debugTag
            debugFrame.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            subview.addSubview(debugFrame)
        } else {
            subview.subviews.first { $0.tag == debugTag }?.removeFromSuperview()
        }
    }
}

private let debugTag = 0xdeba9
