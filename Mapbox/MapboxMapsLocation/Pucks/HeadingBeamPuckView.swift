import Turf
import UIKit

class HeadingBeamPuckView: PrecisePuckView {
    let beamSize: CGFloat = 115.0

    /// The base of the cone beam that shows the heading the device is pointing
    var headingIndicatorLayer: CAShapeLayer = CAShapeLayer()

    /// The cone like beam that shows the heading the device is pointing
    var maskLayer: CAShapeLayer = CAShapeLayer()

    override init(origin: CGPoint) {
        super.init(origin: origin)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with backgroundColor: UIColor, and accuracyRingSize: CGFloat) {
        super.configure(with: backgroundColor, and: accuracyRingSize)
        createAndAddHeadingBeamLayer(withBackgroundColor: self.backgroundColor!)
    }
}

// MARK: Private helper functions that only the Location Manager needs access to
private extension HeadingBeamPuckView {
    func createAndAddHeadingBeamLayer(withBackgroundColor backgroundColor: UIColor) {
        headingIndicatorLayer.backgroundColor = backgroundColor.cgColor
        headingIndicatorLayer.bounds = CGRect(x: 0, y: 0, width: haloSize, height: haloSize)
        headingIndicatorLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        headingIndicatorLayer.contents = gradientImageWithTintColor(tintColor: backgroundColor.cgColor)
        headingIndicatorLayer.contentsGravity = CALayerContentsGravity.bottom
        headingIndicatorLayer.contentsScale = UIScreen.main.scale
        headingIndicatorLayer.opacity = 0.4
        headingIndicatorLayer.shouldRasterize = true
        headingIndicatorLayer.rasterizationScale = UIScreen.main.scale
        headingIndicatorLayer.drawsAsynchronously = true

        maskLayer.frame = headingIndicatorLayer.bounds
        maskLayer.path = clippingMaskForAccuracy(accuracy: 0)
        headingIndicatorLayer.mask = maskLayer

        self.layer.insertSublayer(headingIndicatorLayer, below: puckBorderLayer)
    }

    func gradientImageWithTintColor(tintColor: CGColor) -> CGImage? {
        var image: UIImage?
        let haloRadius = beamSize / 2.0
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        UIGraphicsBeginImageContextWithOptions(CGSize(width: beamSize, height: haloRadius), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // gradient from the tint color to no-alpha tint color
        let gradientLocations: [CGFloat] = [0.0, 1.0]

        let secondColor = tintColor.copy(alpha: 0.0)
        let colorArray = [tintColor, secondColor]

        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colorArray as CFArray,
                                  locations: gradientLocations)

        // draw the gradient from the center point to the edge (full halo radius)
        let centerPoint = CGPoint(x: haloRadius, y: haloRadius)
        context.drawRadialGradient(gradient!,
                                    startCenter: centerPoint,
                                    startRadius: 0.0,
                                    endCenter: centerPoint,
                                    endRadius: haloRadius,
                                    options: CGGradientDrawingOptions(rawValue: 0))

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!.cgImage
    }

    func clippingMaskForAccuracy(accuracy: CGFloat) -> CGPath {
        // size the mask using accuracy, but keep within a good display range
        var clippingDegrees = 90 - accuracy
        clippingDegrees = fmin(clippingDegrees, 70) // most accurate
        clippingDegrees = fmax(clippingDegrees, 10) // least accurate

        let ovalRect = CGRect(x: 0, y: 0, width: beamSize, height: beamSize)
        let ovalPath = UIBezierPath()

        let startAngle = Double((-180 + clippingDegrees)).toRadians()
        let endAngle = Double((-clippingDegrees)).toRadians()

        // clip the oval to ± incoming accuracy degrees (converted to radians), from the top
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY),
                        radius: ovalRect.width / 2.0,
                        startAngle: CGFloat(startAngle),
                        endAngle: CGFloat(endAngle),
                        clockwise: true)

        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()

        return ovalPath.cgPath
    }
}
