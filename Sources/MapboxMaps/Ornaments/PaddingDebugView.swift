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

    init(padding: UIEdgeInsets?) {
        self.padding = padding ?? .zero
        super.init(frame: .zero)
        update()
        self.isUserInteractionEnabled = false
        frameView.layer.borderColor = UIColor.systemGreen.cgColor
        frameView.layer.borderWidth = 1
        self.addSubview(frameView)
        for label in [top, left, bottom, right] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .systemGreen
            label.textColor = .white
            label.font = .safeMonospacedSystemFont(size: 10)
            frameView.addSubview(label)
        }

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
