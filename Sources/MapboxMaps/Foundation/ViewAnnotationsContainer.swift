import UIKit

/// Views conforming to this protocol allow map gestures to pass through them.
protocol AllowsMapGestures {}

final class ViewAnnotationsContainer: UIView, AllowsMapGestures {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        if subviewDebugFrames {
            subviews.forEach(toggleDebugBorder)
        }
    }

    func toggleDebugBorder(_ subview: UIView) {
        subview.subviews.filter { $0.tag == debugTag }.forEach { $0.removeFromSuperview() }

        guard subviewDebugFrames else { return }

        if let boxes = subview.collisionBoxes() {
            for box in boxes {
                subview.addSubview(createDebugFrame(frame: box, color: .red))
            }
        } else {
            subview.addSubview(createDebugFrame(frame: subview.bounds, color: .red))
        }
    }
}

private func createDebugFrame(frame: CGRect, color: UIColor) -> UIView {
    let debugFrame = UIView(frame: frame)
    debugFrame.layer.borderWidth = 1 / ScreenShim.scale
    debugFrame.layer.borderColor = color.withAlphaComponent(0.6).cgColor
    debugFrame.isUserInteractionEnabled = false
    debugFrame.tag = debugTag
    return debugFrame
}

private let debugTag = 0xdeba9
