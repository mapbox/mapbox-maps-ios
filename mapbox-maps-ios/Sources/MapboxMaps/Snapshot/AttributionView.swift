import UIKit
// Consider moving blurring to this view. Unfortunately it doesn't seem
// possible to use UIVisualEffectView as the base class, as the blurring is not
// rendered when used with the current Snapshotter implementation.
//
// Attribution view has a subview label with attributed text
internal final class AttributionView: UIView {

    // Padding around the label. This is also used by `AttributionMeasure` when
    // determining what style of attribution fits within a certain space.
    internal static let padding = CGPoint(x: 10, y: 5)

    internal init(text: NSAttributedString) {
        let label = UILabel()
        label.attributedText = text
        var labelSize = label.sizeThatFits(.zero)
        label.frame.origin = AttributionView.padding
        label.frame.size = labelSize

        super.init(frame: .zero)

        labelSize.width += AttributionView.padding.x*2
        labelSize.height += AttributionView.padding.y*2

        frame = CGRect(origin: .zero, size: labelSize)
        addSubview(label)
        layer.cornerRadius = AttributionView.padding.x
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
