import CoreLocation
import UIKit

internal class MapboxCompassOrnamentView: UIButton {
    private enum Constants {
        static let localizableTableName = "OrnamentsLocalizable"
        static let compassSize = CGSize(width: 40, height: 40)
        static let animationDuration: TimeInterval = 0.3
    }

    internal var containerView = UIImageView()
    internal var containerViewConstraints = [NSLayoutConstraint]()
    internal var visibility: OrnamentVisibility = .adaptive {
        didSet {
            animateVisibilityUpdate()
        }
    }

    internal var tapAction: (() -> Void)?

    private var compassBackgroundColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private var needleColor: UIColor = #colorLiteral(red: 0.9971256852, green: 0.2427211106, blue: 0.196741581, alpha: 1)
    private var lineColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let directionFormatter: CompassDirectionFormatter = {
        let formatter = CompassDirectionFormatter()
        formatter.style = .short
        return formatter
    }()
    /// Should be in range [-pi; pi]
    internal var currentBearing: CLLocationDirection = 0 {
        didSet {
            let adjustedBearing = currentBearing.truncatingRemainder(dividingBy: 360)
            animateVisibilityUpdate()
            self.containerView.transform = CGAffineTransform(rotationAngle: -adjustedBearing.toRadians())
        }
    }

    required internal init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        containerView.isHidden = visibility != .visible
        let bundle = Bundle.mapboxMaps
        accessibilityLabel = NSLocalizedString("COMPASS_A11Y_LABEL",
                                               tableName: Constants.localizableTableName,
                                               bundle: bundle,
                                               value: "Compass",
                                               comment: "Accessibility label")
        accessibilityHint = NSLocalizedString("COMPASS_A11Y_HINT",
                                              tableName: Constants.localizableTableName,
                                              bundle: bundle,
                                              value: "Rotates the map to face due north",
                                              comment: "Accessibility hint")

        containerView.translatesAutoresizingMaskIntoConstraints = false
        if let image = createCompassImage() {
            updateImage(image: image)
        }
        addSubview(containerView)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    func updateImage(image: UIImage?) {
        let image = image ?? createCompassImage()
        guard let image = image else { return }
        NSLayoutConstraint.deactivate(containerViewConstraints)
        containerView.image = image
        containerViewConstraints = [
            widthAnchor.constraint(equalToConstant: image.size.width),
            heightAnchor.constraint(equalToConstant: image.size.height),
            containerView.widthAnchor.constraint(equalToConstant: image.size.width),
            containerView.heightAnchor.constraint(equalToConstant: image.size.height)
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        tapAction?()
    }

    private func animateVisibilityUpdate() {
        switch visibility {
        case .visible:
            animate(toHidden: false)
        case .hidden:
            animate(toHidden: true)
        case .adaptive:
            animate(toHidden: abs(currentBearing) < 0.001)
        }
    }

    private func animate(toHidden isHidden: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerView.isHidden = isHidden
        }
    }

    // swiftlint:disable:next function_body_length
    private func createCompassImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(Constants.compassSize, false, traitCollection.displayScale)

        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let fillColor2 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let fillColor3 = UIColor(red: 1.000, green: 0.235, blue: 0.196, alpha: 1.000)

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: 38, height: 38))
        fillColor.setFill()
        ovalPath.fill()

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 19.68, y: 3.85))
        bezierPath.addLine(to: CGPoint(x: 20.43, y: 3.85))
        bezierPath.addLine(to: CGPoint(x: 20.43, y: 7.6))
        bezierPath.addLine(to: CGPoint(x: 19.68, y: 7.6))
        bezierPath.addLine(to: CGPoint(x: 19.68, y: 3.85))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 26.02, y: 4.96))
        bezierPath.addLine(to: CGPoint(x: 26.71, y: 5.25))
        bezierPath.addLine(to: CGPoint(x: 25.24, y: 8.71))
        bezierPath.addLine(to: CGPoint(x: 24.55, y: 8.41))
        bezierPath.addLine(to: CGPoint(x: 26.02, y: 4.96))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 31.42, y: 8.4))
        bezierPath.addLine(to: CGPoint(x: 31.95, y: 8.93))
        bezierPath.addLine(to: CGPoint(x: 29.29, y: 11.58))
        bezierPath.addLine(to: CGPoint(x: 28.77, y: 11.05))
        bezierPath.addLine(to: CGPoint(x: 31.42, y: 8.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 35.11, y: 13.67))
        bezierPath.addLine(to: CGPoint(x: 35.39, y: 14.36))
        bezierPath.addLine(to: CGPoint(x: 31.91, y: 15.77))
        bezierPath.addLine(to: CGPoint(x: 31.64, y: 15.07))
        bezierPath.addLine(to: CGPoint(x: 35.11, y: 13.67))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 36.5, y: 19.92))
        bezierPath.addLine(to: CGPoint(x: 36.5, y: 20.66))
        bezierPath.addLine(to: CGPoint(x: 32.75, y: 20.66))
        bezierPath.addLine(to: CGPoint(x: 32.75, y: 19.92))
        bezierPath.addLine(to: CGPoint(x: 36.5, y: 19.92))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 35.39, y: 26.26))
        bezierPath.addLine(to: CGPoint(x: 35.09, y: 26.94))
        bezierPath.addLine(to: CGPoint(x: 31.64, y: 25.48))
        bezierPath.addLine(to: CGPoint(x: 31.93, y: 24.79))
        bezierPath.addLine(to: CGPoint(x: 35.39, y: 26.26))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 31.95, y: 31.65))
        bezierPath.addLine(to: CGPoint(x: 31.42, y: 32.18))
        bezierPath.addLine(to: CGPoint(x: 28.77, y: 29.53))
        bezierPath.addLine(to: CGPoint(x: 29.29, y: 29))
        bezierPath.addLine(to: CGPoint(x: 31.95, y: 31.65))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 26.68, y: 35.35))
        bezierPath.addLine(to: CGPoint(x: 25.99, y: 35.63))
        bezierPath.addLine(to: CGPoint(x: 24.58, y: 32.15))
        bezierPath.addLine(to: CGPoint(x: 25.27, y: 31.87))
        bezierPath.addLine(to: CGPoint(x: 26.68, y: 35.35))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 20.43, y: 36.73))
        bezierPath.addLine(to: CGPoint(x: 19.68, y: 36.73))
        bezierPath.addLine(to: CGPoint(x: 19.68, y: 32.98))
        bezierPath.addLine(to: CGPoint(x: 20.43, y: 32.98))
        bezierPath.addLine(to: CGPoint(x: 20.43, y: 36.73))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.09, y: 35.62))
        bezierPath.addLine(to: CGPoint(x: 13.41, y: 35.33))
        bezierPath.addLine(to: CGPoint(x: 14.87, y: 31.88))
        bezierPath.addLine(to: CGPoint(x: 15.56, y: 32.17))
        bezierPath.addLine(to: CGPoint(x: 14.09, y: 35.62))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 8.69, y: 32.18))
        bezierPath.addLine(to: CGPoint(x: 8.17, y: 31.65))
        bezierPath.addLine(to: CGPoint(x: 10.82, y: 29))
        bezierPath.addLine(to: CGPoint(x: 11.35, y: 29.53))
        bezierPath.addLine(to: CGPoint(x: 8.69, y: 32.18))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 5.02, y: 26.94))
        bezierPath.addLine(to: CGPoint(x: 4.73, y: 26.26))
        bezierPath.addLine(to: CGPoint(x: 8.18, y: 24.79))
        bezierPath.addLine(to: CGPoint(x: 8.47, y: 25.48))
        bezierPath.addLine(to: CGPoint(x: 5.02, y: 26.94))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 3.61, y: 20.66))
        bezierPath.addLine(to: CGPoint(x: 3.61, y: 19.92))
        bezierPath.addLine(to: CGPoint(x: 7.36, y: 19.92))
        bezierPath.addLine(to: CGPoint(x: 7.36, y: 20.66))
        bezierPath.addLine(to: CGPoint(x: 3.61, y: 20.66))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 4.73, y: 14.33))
        bezierPath.addLine(to: CGPoint(x: 5.02, y: 13.64))
        bezierPath.addLine(to: CGPoint(x: 8.47, y: 15.11))
        bezierPath.addLine(to: CGPoint(x: 8.18, y: 15.79))
        bezierPath.addLine(to: CGPoint(x: 4.73, y: 14.33))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 8.17, y: 8.93))
        bezierPath.addLine(to: CGPoint(x: 8.69, y: 8.4))
        bezierPath.addLine(to: CGPoint(x: 11.35, y: 11.05))
        bezierPath.addLine(to: CGPoint(x: 10.82, y: 11.58))
        bezierPath.addLine(to: CGPoint(x: 8.17, y: 8.93))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 13.43, y: 5.23))
        bezierPath.addLine(to: CGPoint(x: 14.12, y: 4.96))
        bezierPath.addLine(to: CGPoint(x: 15.53, y: 8.43))
        bezierPath.addLine(to: CGPoint(x: 14.84, y: 8.71))
        bezierPath.addLine(to: CGPoint(x: 13.43, y: 5.23))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        fillColor2.setFill()
        bezierPath.fill()

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 20, y: 10))
        bezier2Path.addLine(to: CGPoint(x: 24, y: 18))
        bezier2Path.addLine(to: CGPoint(x: 16, y: 18))
        bezier2Path.addLine(to: CGPoint(x: 20, y: 10))
        bezier2Path.close()
        bezier2Path.usesEvenOddFillRule = true
        fillColor3.setFill()
        bezier2Path.fill()

        let northFont = UIFont.systemFont(ofSize: 11, weight: .light)
        let northLocalized = directionFormatter.string(from: 0)
        let north = NSAttributedString(string: northLocalized, attributes:
            [
                NSAttributedString.Key.font: northFont,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        let stringRect = CGRect(x: (Constants.compassSize.width - north.size().width) / 2,
                                y: Constants.compassSize.height * 0.435,
                                width: north.size().width,
                                height: north.size().height)
        north.draw(in: stringRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}

private extension CLLocationDirection {
    func toRadians() -> CGFloat {
        return CGFloat(self * Double.pi / 180.0)
    }
}
