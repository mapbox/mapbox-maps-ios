import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

class PrecisePuckView: UIView {
    let precisePuckSize: CGFloat = 22.0
    let haloSize: CGFloat = 115.0

    /// This is the accuracy ring that is provided when zoomed in to represent the radius with in the user is location
    var accuracyRingLayer: CALayer = CALayer()

    /// The white border with a black shadow around the precise puck
    var puckBorderLayer: CALayer = CALayer()

    /// The center blue dot of the puck that contains bleeping animation
    var centerDotLayer: CALayer = CALayer()

    /// The larger translucent ring that has a sonar style animation
    var haloLayer: CALayer = CALayer()

    init(origin: CGPoint) {
        super.init(frame: CGRect.zero)
        self.bounds = CGRect(x: 0.0, y: 0.0, width: precisePuckSize, height: precisePuckSize)
        self.center = origin
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        frame.size = CGSize(width: precisePuckSize, height: precisePuckSize)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = frame.width/2

        createAndAddAccuracyRingLayer(withBackgroundColor: backgroundColor, and: accuracyRingSize)
        createAndAddPuckBorderLayer()
        createAndAddCenterDotLayerWithAnimation(withBackgroundColor: backgroundColor)
        createAndAddHaloLayerWithAnimation(withBackgroundColor: backgroundColor)

        updateAccuracyRing(with: accuracyRingSize)
    }

    func updateAccuracyRing(with accuracyRingSize: CGFloat) {
        if accuracyRingSize > precisePuckSize + 15.0 {
            accuracyRingLayer.isHidden = false
            accuracyRingLayer.bounds = CGRect(x: 0, y: 0, width: accuracyRingSize, height: accuracyRingSize)
            accuracyRingLayer.cornerRadius = accuracyRingSize / 2.0

            // match the halo to the accuracy ring
            haloLayer.bounds = accuracyRingLayer.bounds
            haloLayer.cornerRadius = accuracyRingLayer.cornerRadius
            haloLayer.shouldRasterize = false
        } else {
            accuracyRingLayer.isHidden = true

            haloLayer.bounds = CGRect(x: 0, y: 0, width: haloSize, height: haloSize)
            haloLayer.cornerRadius = haloSize / 2.0
            haloLayer.shouldRasterize = true
            haloLayer.rasterizationScale = UIScreen.main.scale
        }
    }
}

// MARK: Auxilary functions to setup UI Elements
private extension PrecisePuckView {
    func createAndAddAccuracyRingLayer(withBackgroundColor backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        guard let localLayer = circleLayerWithSize(layerSize: accuracyRingSize) else { return }

        accuracyRingLayer = localLayer
        accuracyRingLayer.backgroundColor = backgroundColor.cgColor
        accuracyRingLayer.opacity = 0.1
        accuracyRingLayer.shouldRasterize = false
        accuracyRingLayer.allowsGroupOpacity = false

        self.layer.addSublayer(accuracyRingLayer)
    }

    func createAndAddPuckBorderLayer() {
        guard let localLayer = circleLayerWithSize(layerSize: precisePuckSize) else { return }

        puckBorderLayer = localLayer
        puckBorderLayer.backgroundColor = UIColor.white.cgColor
        puckBorderLayer.shadowColor = UIColor.black.cgColor
        puckBorderLayer.shadowOpacity = 0.25
        puckBorderLayer.shadowPath = UIBezierPath(ovalIn: puckBorderLayer.bounds).cgPath

        self.layer.addSublayer(puckBorderLayer)
    }

    func createAndAddCenterDotLayerWithAnimation(withBackgroundColor backgroundColor: UIColor) {
        guard let localLayer = circleLayerWithSize(layerSize: precisePuckSize * 0.75) else { return }
        centerDotLayer = localLayer
        centerDotLayer.backgroundColor = backgroundColor.cgColor

        // set defaults for the animations
        let animationGroup = loopingAnimationGroupWithDuration(animationDuration: 1.5)
        animationGroup.autoreverses = true
        animationGroup.fillMode = CAMediaTimingFillMode.both

        // scale the dot up and down
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1

        // fade opacity in and out, subtly
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 1

        animationGroup.animations = [pulseAnimation, opacityAnimation]
        centerDotLayer.add(animationGroup, forKey: "animateTransformAndOpacity")

        self.layer.addSublayer(centerDotLayer)
    }

    func createAndAddHaloLayerWithAnimation(withBackgroundColor backgroundColor: UIColor) {
        guard let localLayer = circleLayerWithSize(layerSize: haloSize) else { return }

        haloLayer = localLayer
        haloLayer.backgroundColor = backgroundColor.cgColor
        haloLayer.allowsGroupOpacity = false
        haloLayer.zPosition = -0.1

        // set defaults for the animations
        let animationGroup = loopingAnimationGroupWithDuration(animationDuration: 3.0)

        // scale out radially with initial acceleration
        let boundsAnimation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        boundsAnimation.values = [0, 0.35, 1]
        boundsAnimation.keyTimes = [0, 0.2, 1]

        // go transparent as scaled out, start semi-opaque
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.4, 0]
        opacityAnimation.keyTimes = [0, 0.2, 1]

        animationGroup.animations = [boundsAnimation, opacityAnimation]

        haloLayer.add(animationGroup, forKey: "animateTransformAndOpacity")

        self.layer.addSublayer(haloLayer)
    }

    func loopingAnimationGroupWithDuration(animationDuration: Double) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = Float.infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)

        return animationGroup
    }
}
