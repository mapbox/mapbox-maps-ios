import UIKit

class HeadingArrowPuckView: PrecisePuckView {
    let arrowSize: CGFloat = 8.0

    /// The small arrow that shows the heading
    var arrowLayer: CAShapeLayer = CAShapeLayer()

    override init(origin: CGPoint) {
        super.init(origin: origin)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        super.configure(with: backgroundColor, and: accuracyRingSize)
        createAndAddArrowLayer(withBackgroundColor: backgroundColor)
    }
}

// MARK: Private helper functions that only the Location Manager needs access to
private extension HeadingArrowPuckView {
    func createAndAddArrowLayer(withBackgroundColor backgroundColor: UIColor) {
        let layerSize = super.bounds.size.width + arrowSize

        // x bounds needs a small offset to render correctly on all devices
        arrowLayer.bounds = CGRect(x: -4, y: 0, width: layerSize, height: layerSize)
        arrowLayer.position = CGPoint(x: super.bounds.midX, y: super.bounds.midY)
        arrowLayer.path = arrowPath()
        arrowLayer.fillColor = backgroundColor.cgColor
        arrowLayer.shouldRasterize = true
        arrowLayer.rasterizationScale = UIScreen.main.scale
        arrowLayer.drawsAsynchronously = true
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 1.0
        arrowLayer.lineJoin = CAShapeLayerLineJoin.round

        self.layer.addSublayer(arrowLayer)
    }

    func arrowPath() -> CGPath {
        let center = round(super.bounds.midX)

        let top = CGPoint(x: center, y: 0)
        let left = CGPoint(x: center - arrowSize, y: arrowSize)
        let right = CGPoint(x: center + arrowSize, y: arrowSize)
        let middle = CGPoint(x: center, y: arrowSize / CGFloat.pi)

        let bezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addQuadCurve(to: right, controlPoint: middle)
        bezierPath.addLine(to: top)
        bezierPath.close()

        return bezierPath.cgPath
    }
}
