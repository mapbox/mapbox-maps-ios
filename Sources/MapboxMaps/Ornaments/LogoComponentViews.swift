import UIKit

// MARK: - LogoIconView

/// The Mapbox pin without its background disc.
final class LogoIconView: UIView {

    var pinColor: UIColor = UIColor(white: 0, alpha: 0.65) {
        didSet { setNeedsDisplay() }
    }

    var starColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    override var intrinsicContentSize: CGSize {
        LogoView.LogoSize.defaultCompactSize
    }

    init() {
        let size = LogoView.LogoSize.defaultCompactSize
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        contentMode = .redraw
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let referenceSize = LogoView.LogoSize.defaultCompactSize
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: rect.width / referenceSize.width, y: rect.height / referenceSize.height)
        LogoView.drawIconInCurrentContext(primaryColor: starColor, accentColor: pinColor, showBackground: false)
        context.restoreGState()
    }
}

// MARK: - LogoWordmarkView

/// The "mapbox" wordmark without the icon.
final class LogoWordmarkView: UIView {

    private static let referenceSize = CGSize(
        width: LogoView.LogoSize.defaultRegularSize.width - LogoView.LogoSize.defaultCompactSize.width,
        height: LogoView.LogoSize.defaultRegularSize.height
    )

    var letterColor: UIColor = UIColor(white: 0, alpha: 0.7) {
        didSet { setNeedsDisplay() }
    }

    /// Letter details, such as counters.
    var detailColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    override var intrinsicContentSize: CGSize {
        LogoWordmarkView.referenceSize
    }

    init() {
        let size = LogoWordmarkView.referenceSize
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        contentMode = .redraw
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let ref = LogoWordmarkView.referenceSize
        let iconWidth = LogoView.LogoSize.defaultCompactSize.width

        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: rect.width / ref.width, y: rect.height / ref.height)
        // The wordmark paths start after the icon in the full logo.
        context.translateBy(x: -iconWidth, y: 0)
        LogoView.drawWordmarkInCurrentContext(primaryColor: letterColor, accentColor: detailColor)
        context.restoreGState()
    }
}

// MARK: - ChevronView

/// Drawn by hand, not an SF Symbol, to match the logo's two-tone style.
final class ChevronView: UIView {

    private static let referenceSize = CGSize(width: 9, height: 14)
    private static let outlineWidth: CGFloat = 3.2
    private static let strokeWidth: CGFloat = 1.7

    var shapeColor: UIColor = UIColor(white: 0, alpha: 0.7) {
        didSet { setNeedsDisplay() }
    }

    /// Halo that keeps the chevron readable on a translucent pill.
    var outlineColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    override var intrinsicContentSize: CGSize {
        ChevronView.referenceSize
    }

    init() {
        super.init(frame: CGRect(origin: .zero, size: ChevronView.referenceSize))
        backgroundColor = .clear
        contentMode = .redraw
        isAccessibilityElement = false
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let ref = ChevronView.referenceSize

        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: rect.width / ref.width, y: rect.height / ref.height)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 2.5, y: 2.5))
        path.addLine(to: CGPoint(x: 6.5, y: 7))
        path.addLine(to: CGPoint(x: 2.5, y: 11.5))
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        outlineColor.setStroke()
        path.lineWidth = ChevronView.outlineWidth
        path.stroke()

        shapeColor.setStroke()
        path.lineWidth = ChevronView.strokeWidth
        path.stroke()

        context.restoreGState()
    }
}
