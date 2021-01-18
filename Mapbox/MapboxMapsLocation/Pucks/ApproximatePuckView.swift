import UIKit

internal class ApproximatePuckView: UIView {
    let approximatePuckSize: CGFloat = 85.0

    var approximateLayer: CALayer = CALayer()

    init(origin: CGPoint) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: approximatePuckSize, height: approximatePuckSize))
        self.center = origin
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        let backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
        self.alpha = 0.25
        self.layer.cornerRadius = frame.width/2

        createAndAddApproximateLayer(withBackgroundColor: backgroundColor, and: accuracyRingSize)
    }
}

// MARK: Auxilary functions to setup UI Elements
private extension ApproximatePuckView {
    func createAndAddApproximateLayer(withBackgroundColor backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        guard let localLayer = circleLayerWithSize(layerSize: accuracyRingSize) else { return }

        approximateLayer = localLayer
        approximateLayer.backgroundColor = backgroundColor.cgColor
        approximateLayer.opacity = 0.25
        approximateLayer.shouldRasterize = false
        approximateLayer.allowsGroupOpacity = false
        approximateLayer.borderWidth = 2.0
        approximateLayer.borderColor = UIColor.black.cgColor

        self.layer.addSublayer(approximateLayer)
    }
}
