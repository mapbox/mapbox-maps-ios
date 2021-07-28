// Consider moving blurring to this view. Unfortunately it doesn't seem
// possible to use UIVisualEffectView as the base class, as the blurring is not
// rendered when used with the current Snapshotter implementation.
//
// Attribution view has a subview label with attributed text
internal final class AttributionView: UIView {

    private let labelMargin = CGPoint(x: 10, y: 5)

    init(text: NSAttributedString) {
        // Label
        let label = UILabel()
        label.attributedText = text
        var labelSize = label.sizeThatFits(.zero)
        label.frame.origin = labelMargin
        label.frame.size = labelSize

        super.init(frame: .zero)

        labelSize.width += labelMargin.x*2
        labelSize.height += labelMargin.y*2

        frame = CGRect(origin: .zero, size: labelSize)
        addSubview(label)
        layer.cornerRadius = labelMargin.x
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
