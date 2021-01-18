import UIKit

class ArrowPuckView: UIView {
    let arrowBackgroundSize: CGFloat = 45.0
    let arrowPuckSize: CGFloat = 22.5

    /// The white circle background for the arrow
    var puckArrowBackgroundLayer: CALayer = CALayer()

    /// The actual bezier arrow that is displayed
    var puckArrowLayer: CAShapeLayer = CAShapeLayer()

    init(origin: CGPoint) {
        super.init(frame: CGRect.zero)
        self.bounds = CGRect(x: 0.0, y: 0.0, width: arrowPuckSize, height: arrowPuckSize)
        self.center = origin
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with backgroundColor: UIColor) {
        layer.cornerRadius = frame.width/2

        createAndAddPuckArrowBackgroundLayer()
        createAndAddPuckArrowLayer()
    }
}

// MARK: Auxilary functions to setup UI Elements
private extension ArrowPuckView {
    func createAndAddPuckArrowBackgroundLayer() {
        guard let localLayer = circleLayerWithSize(layerSize: arrowBackgroundSize) else { return }

        puckArrowBackgroundLayer = localLayer
        puckArrowBackgroundLayer.backgroundColor = UIColor.white.cgColor
        puckArrowBackgroundLayer.shadowColor = UIColor.black.cgColor
        puckArrowBackgroundLayer.shadowOpacity = 0.25
        puckArrowBackgroundLayer.shadowPath = UIBezierPath(rect: puckArrowBackgroundLayer.bounds).cgPath

        self.layer.addSublayer(puckArrowBackgroundLayer)
    }

    func createAndAddPuckArrowLayer() {
        puckArrowLayer = CAShapeLayer(layer: layer)
        puckArrowLayer.path = puckArrowBezier().cgPath
        puckArrowLayer.fillColor = tintColor.cgColor
        puckArrowLayer.bounds = CGRect(x: 0, y: 0, width: round(arrowPuckSize), height: round(arrowPuckSize))
        puckArrowLayer.position = CGPoint(x: super.bounds.midX, y: super.bounds.midY)
        puckArrowLayer.shouldRasterize = true
        puckArrowLayer.rasterizationScale = UIScreen.main.scale
        puckArrowLayer.drawsAsynchronously = true

        puckArrowLayer.lineJoin = CAShapeLayerLineJoin(rawValue: "round")
        puckArrowLayer.lineWidth = 1.0
        puckArrowLayer.strokeColor = puckArrowLayer.fillColor

        self.layer.addSublayer(puckArrowLayer)
    }

    func puckArrowBezier() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: arrowPuckSize * 0.5, y: 0.0))
        bezierPath.addLine(to: CGPoint(x: arrowPuckSize * 0.1, y: arrowPuckSize))
        bezierPath.addLine(to: CGPoint(x: arrowPuckSize * 0.5, y: arrowPuckSize * 0.65))
        bezierPath.addLine(to: CGPoint(x: arrowPuckSize * 0.9, y: arrowPuckSize))
        bezierPath.addLine(to: CGPoint(x: arrowPuckSize * 0.5, y: 0))
        bezierPath.close()

        return bezierPath
    }
}
