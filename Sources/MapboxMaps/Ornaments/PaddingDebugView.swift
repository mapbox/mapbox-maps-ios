import UIKit

final class PaddingDebugView: UIView {
    var padding: UIEdgeInsets {
        didSet {
            guard padding != oldValue else { return }
            update()
            setNeedsLayout() // update frame
        }
    }
    private var frameView = UIView()
    private var top = UILabel()
    private var left = UILabel()
    private var bottom = UILabel()
    private var right = UILabel()
    private var cross = CAShapeLayer()

    init(padding: UIEdgeInsets?) {
        self.padding = padding ?? .zero
        super.init(frame: .zero)
        update()
        self.isUserInteractionEnabled = false

        let color = UIColor.systemGreen
        frameView.layer.borderColor = color.cgColor
        frameView.layer.borderWidth = 1
        frameView.layer.addSublayer(cross)
        self.addSubview(frameView)
        for label in [top, left, bottom, right] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = color
            label.textColor = .white
            label.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            frameView.addSubview(label)
        }

        let crossSize = 15.0
        cross.frame = CGRect(x: 0, y: 0, width: crossSize, height: crossSize)
        cross.path = UIBezierPath.crossPath(size: crossSize).cgPath
        cross.strokeColor = color.cgColor

        NSLayoutConstraint.activate([
            top.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            top.topAnchor.constraint(equalTo: frameView.topAnchor),
            left.centerYAnchor.constraint(equalTo: frameView.centerYAnchor),
            left.leftAnchor.constraint(equalTo: frameView.leftAnchor),
            bottom.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            bottom.bottomAnchor.constraint(equalTo: frameView.bottomAnchor),
            right.centerYAnchor.constraint(equalTo: frameView.centerYAnchor),
            right.rightAnchor.constraint(equalTo: frameView.rightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frameView.frame = bounds.inset(by: padding)
        let frameSize = frameView.bounds.size

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        cross.frame.origin = CGPoint(
            x: (frameSize.width - cross.frame.width) / 2,
            y: (frameSize.height - cross.frame.height) / 2)
        CATransaction.commit()
    }

    private func update() {
        func format(_ value: CGFloat) -> String {
            String(format: "%.1f\n", value)
        }
        top.text = format(padding.top)
        left.text = format(padding.left)
        bottom.text = format(padding.bottom)
        right.text = format(padding.right)
    }
}

private extension UIBezierPath {
    static func crossPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let half = size / 2
        path.move(to: CGPoint(x: half, y: 0))
        path.addLine(to: CGPoint(x: half, y: size))
        path.move(to: CGPoint(x: 0, y: half))
        path.addLine(to: CGPoint(x: size, y: half))
        path.close()
        return path
    }
}
