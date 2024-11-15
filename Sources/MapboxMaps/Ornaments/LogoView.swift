import UIKit
@_implementationOnly import MapboxCommon_Private

// swiftlint:disable:next type_body_length
internal class LogoView: UIView {

    internal enum LogoSize: Equatable {

        static let defaultRegularSize = CGSize(width: 85, height: 21)
        static let defaultCompactSize = CGSize(width: 21, height: 21)

        case regular(size: CGSize = defaultRegularSize)
        case compact(size: CGSize = defaultCompactSize)
        case none

        var size: CGSize {
            switch self {
            case let .regular(size),
                 let .compact(size):
                return size

            case .none:
                return .zero
            }
        }

        var referenceSize: CGSize {
            switch self {
            case .regular:
                return LogoSize.defaultRegularSize
            case .compact:
                return LogoSize.defaultCompactSize
            case .none:
                return .zero
            }
        }
    }

    internal var logoSize: LogoSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    private var resizing: ResizingBehavior

    public override var isHidden: Bool {
        didSet {
            if isHidden {
                Log.warning("The Mapbox logo wordmark must remain enabled in accordance with our Terms of Service. See https://www.mapbox.com/legal/tos for more details.", category: "Ornaments")
            }
        }
    }

    internal override var intrinsicContentSize: CGSize {
        return logoSize.size
    }

    internal init(logoSize: LogoSize, resizing: ResizingBehavior = .aspectFit) {
        self.logoSize = logoSize
        self.resizing = resizing

        let frame = CGRect(origin: .zero, size: logoSize.size)
        super.init(frame: frame)

        backgroundColor = .clear
        contentMode = .redraw
    }

    internal override func draw(_ rect: CGRect) {
        drawMapboxLogoOrnamentViewFullCanvas(frame: rect, resizing: resizing)
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Color declarations
    private let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.900)
    private let fillColor2 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.350)

    // Drawing methods generated from PaintCode
    // swiftlint:disable:next function_body_length
    internal func drawMapboxLogoOrnamentViewFullCanvas(frame targetFrame: CGRect,
                                                       resizing: ResizingBehavior = .aspectFit) {
        // General declarations
        let context = UIGraphicsGetCurrentContext()!

        // Resize to target frame
        context.saveGState()
        let rect = CGRect(origin: .zero, size: logoSize.referenceSize)
        let resizedFrame: CGRect = resizing.apply(rect: rect, target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / rect.width, y: resizedFrame.height / rect.height)

        if case .regular = logoSize {
            drawMapboxWordmark()
        }

        let bezier12Path = UIBezierPath()
        bezier12Path.move(to: CGPoint(x: 10.5, y: 1.24))
        bezier12Path.addCurve(to: CGPoint(x: 1.25, y: 10.49),
                              controlPoint1: CGPoint(x: 5.39, y: 1.24),
                              controlPoint2: CGPoint(x: 1.25, y: 5.39))
        bezier12Path.addCurve(to: CGPoint(x: 10.5, y: 19.74),
                              controlPoint1: CGPoint(x: 1.25, y: 15.59),
                              controlPoint2: CGPoint(x: 5.4, y: 19.74))
        bezier12Path.addCurve(to: CGPoint(x: 19.75, y: 10.49),
                              controlPoint1: CGPoint(x: 15.6, y: 19.74),
                              controlPoint2: CGPoint(x: 19.75, y: 15.59))
        bezier12Path.addCurve(to: CGPoint(x: 10.5, y: 1.24),
                              controlPoint1: CGPoint(x: 19.75, y: 5.38),
                              controlPoint2: CGPoint(x: 15.61, y: 1.24))
        bezier12Path.close()
        bezier12Path.move(to: CGPoint(x: 14.89, y: 12.77))
        bezier12Path.addCurve(to: CGPoint(x: 8.19, y: 15.08),
                              controlPoint1: CGPoint(x: 12.96, y: 14.7),
                              controlPoint2: CGPoint(x: 10.11, y: 15.08))
        bezier12Path.addCurve(to: CGPoint(x: 6.09, y: 14.92),
                              controlPoint1: CGPoint(x: 7.49, y: 15.08),
                              controlPoint2: CGPoint(x: 6.78, y: 15.03))
        bezier12Path.addCurve(to: CGPoint(x: 8.23, y: 6.11),
                              controlPoint1: CGPoint(x: 6.09, y: 14.92),
                              controlPoint2: CGPoint(x: 5.07, y: 9.28))
        bezier12Path.addCurve(to: CGPoint(x: 11.36, y: 4.83),
                              controlPoint1: CGPoint(x: 9.06, y: 5.28),
                              controlPoint2: CGPoint(x: 10.18, y: 4.83))
        bezier12Path.addCurve(to: CGPoint(x: 14.75, y: 6.25),
                              controlPoint1: CGPoint(x: 12.63, y: 4.83),
                              controlPoint2: CGPoint(x: 13.85, y: 5.34))
        bezier12Path.addCurve(to: CGPoint(x: 14.89, y: 12.77),
                              controlPoint1: CGPoint(x: 16.59, y: 8.09),
                              controlPoint2: CGPoint(x: 16.64, y: 11))
        bezier12Path.close()
        fillColor.setFill()
        bezier12Path.fill()

        // Bezier #13
        let bezier13Path = UIBezierPath()
        bezier13Path.move(to: CGPoint(x: 10.5, y: -0.01))
        bezier13Path.addCurve(to: CGPoint(x: 0, y: 10.49),
                              controlPoint1: CGPoint(x: 4.7, y: -0.01),
                              controlPoint2: CGPoint(x: 0, y: 4.7))
        bezier13Path.addCurve(to: CGPoint(x: 10.5, y: 20.99),
                              controlPoint1: CGPoint(x: 0, y: 16.28),
                              controlPoint2: CGPoint(x: 4.7, y: 20.99))
        bezier13Path.addCurve(to: CGPoint(x: 21, y: 10.49),
                              controlPoint1: CGPoint(x: 16.3, y: 20.99),
                              controlPoint2: CGPoint(x: 21, y: 16.29))
        bezier13Path.addCurve(to: CGPoint(x: 10.5, y: -0.01),
                              controlPoint1: CGPoint(x: 20.99, y: 4.7),
                              controlPoint2: CGPoint(x: 16.3, y: -0.01))
        bezier13Path.close()
        bezier13Path.move(to: CGPoint(x: 10.5, y: 19.74))
        bezier13Path.addCurve(to: CGPoint(x: 1.25, y: 10.49),
                              controlPoint1: CGPoint(x: 5.39, y: 19.74),
                              controlPoint2: CGPoint(x: 1.25, y: 15.59))
        bezier13Path.addCurve(to: CGPoint(x: 10.5, y: 1.23),
                              controlPoint1: CGPoint(x: 1.25, y: 5.39),
                              controlPoint2: CGPoint(x: 5.39, y: 1.23))
        bezier13Path.addCurve(to: CGPoint(x: 19.75, y: 10.48),
                              controlPoint1: CGPoint(x: 15.61, y: 1.23),
                              controlPoint2: CGPoint(x: 19.75, y: 5.38))
        bezier13Path.addCurve(to: CGPoint(x: 10.5, y: 19.74),
                              controlPoint1: CGPoint(x: 19.75, y: 15.61), controlPoint2: CGPoint(x: 15.61, y: 19.74))
        bezier13Path.close()
        fillColor2.setFill()
        bezier13Path.fill()

        // Bezier #14
        let bezier14Path = UIBezierPath()
        bezier14Path.move(to: CGPoint(x: 14.74, y: 6.25))
        bezier14Path.addCurve(to: CGPoint(x: 8.23, y: 6.1),
                              controlPoint1: CGPoint(x: 12.9, y: 4.41),
                              controlPoint2: CGPoint(x: 9.98, y: 4.35))
        bezier14Path.addCurve(to: CGPoint(x: 6.09, y: 14.91),
                              controlPoint1: CGPoint(x: 5.07, y: 9.27),
                              controlPoint2: CGPoint(x: 6.09, y: 14.91))
        bezier14Path.addCurve(to: CGPoint(x: 14.9, y: 12.77),
                              controlPoint1: CGPoint(x: 6.09, y: 14.91),
                              controlPoint2: CGPoint(x: 11.73, y: 15.93))
        bezier14Path.addCurve(to: CGPoint(x: 14.74, y: 6.25),
                              controlPoint1: CGPoint(x: 16.64, y: 11),
                              controlPoint2: CGPoint(x: 16.59, y: 8.09))
        bezier14Path.close()
        bezier14Path.move(to: CGPoint(x: 12.47, y: 10.34))
        bezier14Path.addLine(to: CGPoint(x: 11.56, y: 12.21))
        bezier14Path.addLine(to: CGPoint(x: 10.66, y: 10.34))
        bezier14Path.addLine(to: CGPoint(x: 8.8, y: 9.43))
        bezier14Path.addLine(to: CGPoint(x: 10.66, y: 8.53))
        bezier14Path.addLine(to: CGPoint(x: 11.56, y: 6.66))
        bezier14Path.addLine(to: CGPoint(x: 12.47, y: 8.53))
        bezier14Path.addLine(to: CGPoint(x: 14.33, y: 9.43))
        bezier14Path.addLine(to: CGPoint(x: 12.47, y: 10.34))
        bezier14Path.close()
        fillColor2.setFill()
        bezier14Path.fill()

        // Bezier #15
        context.saveGState()
        context.translateBy(x: 11.55, y: 9.45)
        context.rotate(by: -0.05 * CGFloat.pi/180)

        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 0, y: -2.75))
        starPath.addLine(to: CGPoint(x: 0.92, y: -0.92))
        starPath.addLine(to: CGPoint(x: 2.75, y: 0))
        starPath.addLine(to: CGPoint(x: 0.92, y: 0.92))
        starPath.addLine(to: CGPoint(x: 0, y: 2.75))
        starPath.addLine(to: CGPoint(x: -0.92, y: 0.92))
        starPath.addLine(to: CGPoint(x: -2.75, y: 0))
        starPath.addLine(to: CGPoint(x: -0.92, y: -0.92))
        starPath.close()
        fillColor.setFill()
        starPath.fill()

        context.restoreGState()

        context.restoreGState()

    }

    // swiftlint:disable:next function_body_length
    private func drawMapboxWordmark() {
        // Bezier #1
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 83.25, y: 14.26))
        bezierPath.addCurve(to: CGPoint(x: 83.04, y: 14.47),
                            controlPoint1: CGPoint(x: 83.25, y: 14.38),
                            controlPoint2: CGPoint(x: 83.16, y: 14.47))
        bezierPath.addLine(to: CGPoint(x: 81.43, y: 14.47))
        bezierPath.addCurve(to: CGPoint(x: 81.13, y: 14.3),
                            controlPoint1: CGPoint(x: 81.3, y: 14.47),
                            controlPoint2: CGPoint(x: 81.19, y: 14.41))
        bezierPath.addLine(to: CGPoint(x: 79.69, y: 11.91))
        bezierPath.addLine(to: CGPoint(x: 78.25, y: 14.3))
        bezierPath.addCurve(to: CGPoint(x: 77.95, y: 14.47),
                            controlPoint1: CGPoint(x: 78.19, y: 14.41),
                            controlPoint2: CGPoint(x: 78.07, y: 14.47))
        bezierPath.addLine(to: CGPoint(x: 76.34, y: 14.47))
        bezierPath.addCurve(to: CGPoint(x: 76.22, y: 14.44),
                            controlPoint1: CGPoint(x: 76.3, y: 14.47),
                            controlPoint2: CGPoint(x: 76.26, y: 14.46))
        bezierPath.addCurve(to: CGPoint(x: 76.16, y: 14.16),
                            controlPoint1: CGPoint(x: 76.13, y: 14.38),
                            controlPoint2: CGPoint(x: 76.09, y: 14.25))
        bezierPath.addLine(to: CGPoint(x: 76.16, y: 14.16))
        bezierPath.addLine(to: CGPoint(x: 78.59, y: 10.48))
        bezierPath.addLine(to: CGPoint(x: 76.2, y: 6.84))
        bezierPath.addCurve(to: CGPoint(x: 76.17, y: 6.72),
                            controlPoint1: CGPoint(x: 76.18, y: 6.81),
                            controlPoint2: CGPoint(x: 76.17, y: 6.77))
        bezierPath.addCurve(to: CGPoint(x: 76.38, y: 6.51),
                            controlPoint1: CGPoint(x: 76.17, y: 6.6),
                            controlPoint2: CGPoint(x: 76.26, y: 6.51))
        bezierPath.addLine(to: CGPoint(x: 77.99, y: 6.51))
        bezierPath.addCurve(to: CGPoint(x: 78.29, y: 6.68),
                            controlPoint1: CGPoint(x: 78.12, y: 6.51),
                            controlPoint2: CGPoint(x: 78.23, y: 6.57))
        bezierPath.addLine(to: CGPoint(x: 79.7, y: 9.04))
        bezierPath.addLine(to: CGPoint(x: 81.1, y: 6.69))
        bezierPath.addCurve(to: CGPoint(x: 81.4, y: 6.52),
                            controlPoint1: CGPoint(x: 81.16, y: 6.58), controlPoint2: CGPoint(x: 81.28, y: 6.52))
        bezierPath.addLine(to: CGPoint(x: 83, y: 6.52))
        bezierPath.addCurve(to: CGPoint(x: 83.12, y: 6.55),
                            controlPoint1: CGPoint(x: 83.04, y: 6.52),
                            controlPoint2: CGPoint(x: 83.08, y: 6.53))
        bezierPath.addCurve(to: CGPoint(x: 83.18, y: 6.83),
                            controlPoint1: CGPoint(x: 83.21, y: 6.61), controlPoint2: CGPoint(x: 83.25, y: 6.74))
        bezierPath.addLine(to: CGPoint(x: 83.18, y: 6.83))
        bezierPath.addLine(to: CGPoint(x: 80.81, y: 10.46))
        bezierPath.addLine(to: CGPoint(x: 83.24, y: 14.13))
        bezierPath.addCurve(to: CGPoint(x: 83.25, y: 14.26),
                            controlPoint1: CGPoint(x: 83.24, y: 14.18),
                            controlPoint2: CGPoint(x: 83.25, y: 14.22))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()

        // Bezier #2
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 66.24, y: 9.59))
        bezier2Path.addCurve(to: CGPoint(x: 62.4, y: 6.31),
                             controlPoint1: CGPoint(x: 65.85, y: 7.71),
                             controlPoint2: CGPoint(x: 64.28, y: 6.31))
        bezier2Path.addCurve(to: CGPoint(x: 59.67, y: 7.49),
                             controlPoint1: CGPoint(x: 61.37, y: 6.31),
                             controlPoint2: CGPoint(x: 60.37, y: 6.73))
        bezier2Path.addLine(to: CGPoint(x: 59.67, y: 3.51))
        bezier2Path.addCurve(to: CGPoint(x: 59.44, y: 3.28),
                             controlPoint1: CGPoint(x: 59.67, y: 3.38),
                             controlPoint2: CGPoint(x: 59.57, y: 3.28))
        bezier2Path.addLine(to: CGPoint(x: 58.04, y: 3.28))
        bezier2Path.addCurve(to: CGPoint(x: 57.81, y: 3.51),
                             controlPoint1: CGPoint(x: 57.91, y: 3.28),
                             controlPoint2: CGPoint(x: 57.81, y: 3.39))
        bezier2Path.addLine(to: CGPoint(x: 57.81, y: 14.23))
        bezier2Path.addCurve(to: CGPoint(x: 58.04, y: 14.46),
                             controlPoint1: CGPoint(x: 57.81, y: 14.36),
                             controlPoint2: CGPoint(x: 57.91, y: 14.46))
        bezier2Path.addLine(to: CGPoint(x: 59.44, y: 14.46))
        bezier2Path.addCurve(to: CGPoint(x: 59.67, y: 14.23),
                             controlPoint1: CGPoint(x: 59.57, y: 14.46),
                             controlPoint2: CGPoint(x: 59.67, y: 14.35))
        bezier2Path.addLine(to: CGPoint(x: 59.67, y: 13.5))
        bezier2Path.addCurve(to: CGPoint(x: 62.4, y: 14.68),
                             controlPoint1: CGPoint(x: 60.38, y: 14.25),
                             controlPoint2: CGPoint(x: 61.37, y: 14.68))
        bezier2Path.addCurve(to: CGPoint(x: 66.24, y: 11.39),
                             controlPoint1: CGPoint(x: 64.28, y: 14.68),
                             controlPoint2: CGPoint(x: 65.85, y: 13.27))
        bezier2Path.addCurve(to: CGPoint(x: 66.24, y: 9.59),
                             controlPoint1: CGPoint(x: 66.37, y: 10.79),
                             controlPoint2: CGPoint(x: 66.37, y: 10.18))
        bezier2Path.addLine(to: CGPoint(x: 66.24, y: 9.59))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 62.08, y: 13))
        bezier2Path.addCurve(to: CGPoint(x: 59.67, y: 10.52),
                             controlPoint1: CGPoint(x: 60.76, y: 13),
                             controlPoint2: CGPoint(x: 59.69, y: 11.89))
        bezier2Path.addLine(to: CGPoint(x: 59.67, y: 10.46))
        bezier2Path.addCurve(to: CGPoint(x: 62.08, y: 7.98),
                             controlPoint1: CGPoint(x: 59.69, y: 9.08),
                             controlPoint2: CGPoint(x: 60.76, y: 7.98))
        bezier2Path.addCurve(to: CGPoint(x: 64.5, y: 10.49),
                             controlPoint1: CGPoint(x: 63.4, y: 7.98),
                             controlPoint2: CGPoint(x: 64.5, y: 9.1))
        bezier2Path.addCurve(to: CGPoint(x: 62.08, y: 13),
                             controlPoint1: CGPoint(x: 64.5, y: 11.88),
                             controlPoint2: CGPoint(x: 63.41, y: 13))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()

        // Bezier #3
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 71.67, y: 6.32))
        bezier3Path.addCurve(to: CGPoint(x: 67.51, y: 9.61),
                             controlPoint1: CGPoint(x: 69.69, y: 6.31),
                             controlPoint2: CGPoint(x: 67.95, y: 7.67))
        bezier3Path.addCurve(to: CGPoint(x: 67.51, y: 11.38),
                             controlPoint1: CGPoint(x: 67.38, y: 10.2),
                             controlPoint2: CGPoint(x: 67.38, y: 10.8))
        bezier3Path.addCurve(to: CGPoint(x: 71.68, y: 14.68),
                             controlPoint1: CGPoint(x: 67.95, y: 13.32),
                             controlPoint2: CGPoint(x: 69.68, y: 14.7))
        bezier3Path.addCurve(to: CGPoint(x: 75.94, y: 10.49),
                             controlPoint1: CGPoint(x: 74.03, y: 14.68),
                             controlPoint2: CGPoint(x: 75.94, y: 12.81))
        bezier3Path.addCurve(to: CGPoint(x: 71.67, y: 6.32),
                             controlPoint1: CGPoint(x: 75.94, y: 8.17),
                             controlPoint2: CGPoint(x: 74.04, y: 6.32))
        bezier3Path.close()
        bezier3Path.move(to: CGPoint(x: 71.65, y: 13.01))
        bezier3Path.addCurve(to: CGPoint(x: 69.23, y: 10.5),
                             controlPoint1: CGPoint(x: 70.32, y: 13.01),
                             controlPoint2: CGPoint(x: 69.23, y: 11.89))
        bezier3Path.addCurve(to: CGPoint(x: 71.65, y: 7.98),
                             controlPoint1: CGPoint(x: 69.23, y: 9.11),
                             controlPoint2: CGPoint(x: 70.31, y: 7.98))
        bezier3Path.addCurve(to: CGPoint(x: 74.07, y: 10.49),
                             controlPoint1: CGPoint(x: 72.98, y: 7.98),
                             controlPoint2: CGPoint(x: 74.07, y: 9.1))
        bezier3Path.addCurve(to: CGPoint(x: 71.65, y: 13.01),
                             controlPoint1: CGPoint(x: 74.07, y: 11.88),
                             controlPoint2: CGPoint(x: 72.99, y: 13))
        bezier3Path.addLine(to: CGPoint(x: 71.65, y: 13.01))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()

        // Bezier #4
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 62.08, y: 7.98))
        bezier4Path.addCurve(to: CGPoint(x: 59.67, y: 10.46),
                             controlPoint1: CGPoint(x: 60.76, y: 7.98),
                             controlPoint2: CGPoint(x: 59.69, y: 9.09))
        bezier4Path.addLine(to: CGPoint(x: 59.67, y: 10.52))
        bezier4Path.addCurve(to: CGPoint(x: 62.08, y: 13),
                             controlPoint1: CGPoint(x: 59.68, y: 11.9),
                             controlPoint2: CGPoint(x: 60.75, y: 13))
        bezier4Path.addCurve(to: CGPoint(x: 64.5, y: 10.49),
                             controlPoint1: CGPoint(x: 63.41, y: 13),
                             controlPoint2: CGPoint(x: 64.5, y: 11.88))
        bezier4Path.addCurve(to: CGPoint(x: 62.08, y: 7.98),
                             controlPoint1: CGPoint(x: 64.5, y: 9.1),
                             controlPoint2: CGPoint(x: 63.41, y: 7.98))
        bezier4Path.close()
        bezier4Path.move(to: CGPoint(x: 62.08, y: 11.76))
        bezier4Path.addCurve(to: CGPoint(x: 60.91, y: 10.51),
                             controlPoint1: CGPoint(x: 61.45, y: 11.76),
                             controlPoint2: CGPoint(x: 60.94, y: 11.2))
        bezier4Path.addLine(to: CGPoint(x: 60.91, y: 10.47))
        bezier4Path.addCurve(to: CGPoint(x: 62.08, y: 9.22),
                             controlPoint1: CGPoint(x: 60.92, y: 9.78), controlPoint2: CGPoint(x: 61.45, y: 9.22))
        bezier4Path.addCurve(to: CGPoint(x: 63.25, y: 10.49),
                             controlPoint1: CGPoint(x: 62.71, y: 9.22), controlPoint2: CGPoint(x: 63.25, y: 9.79))
        bezier4Path.addCurve(to: CGPoint(x: 62.08, y: 11.76),
                             controlPoint1: CGPoint(x: 63.24, y: 11.2), controlPoint2: CGPoint(x: 62.73, y: 11.76))
        bezier4Path.close()
        fillColor2.setFill()
        bezier4Path.fill()

        // Bezier #5
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 71.65, y: 7.98))
        bezier5Path.addCurve(to: CGPoint(x: 69.23, y: 10.49),
                             controlPoint1: CGPoint(x: 70.32, y: 7.98),
                             controlPoint2: CGPoint(x: 69.23, y: 9.1))
        bezier5Path.addCurve(to: CGPoint(x: 71.65, y: 13),
                             controlPoint1: CGPoint(x: 69.23, y: 11.88),
                             controlPoint2: CGPoint(x: 70.32, y: 13))
        bezier5Path.addCurve(to: CGPoint(x: 74.07, y: 10.49),
                             controlPoint1: CGPoint(x: 72.98, y: 13),
                             controlPoint2: CGPoint(x: 74.07, y: 11.88))
        bezier5Path.addCurve(to: CGPoint(x: 71.65, y: 7.98),
                             controlPoint1: CGPoint(x: 74.07, y: 9.1),
                             controlPoint2: CGPoint(x: 72.99, y: 7.98))
        bezier5Path.close()
        bezier5Path.move(to: CGPoint(x: 71.65, y: 11.76))
        bezier5Path.addCurve(to: CGPoint(x: 70.48, y: 10.49),
                             controlPoint1: CGPoint(x: 71.01, y: 11.76),
                             controlPoint2: CGPoint(x: 70.48, y: 11.19))
        bezier5Path.addCurve(to: CGPoint(x: 71.65, y: 9.23),
                             controlPoint1: CGPoint(x: 70.48, y: 9.79),
                             controlPoint2: CGPoint(x: 71.01, y: 9.23))
        bezier5Path.addCurve(to: CGPoint(x: 72.82, y: 10.5),
                             controlPoint1: CGPoint(x: 72.29, y: 9.23),
                             controlPoint2: CGPoint(x: 72.82, y: 9.8))
        bezier5Path.addCurve(to: CGPoint(x: 71.65, y: 11.76),
                             controlPoint1: CGPoint(x: 72.82, y: 11.21),
                             controlPoint2: CGPoint(x: 72.29, y: 11.76))
        bezier5Path.close()
        fillColor2.setFill()
        bezier5Path.fill()

        // Bezier #6
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 45.74, y: 6.53))
        bezier6Path.addLine(to: CGPoint(x: 44.34, y: 6.53))
        bezier6Path.addCurve(to: CGPoint(x: 44.11, y: 6.76),
                             controlPoint1: CGPoint(x: 44.21, y: 6.53),
                             controlPoint2: CGPoint(x: 44.11, y: 6.64))
        bezier6Path.addLine(to: CGPoint(x: 44.11, y: 7.49))
        bezier6Path.addCurve(to: CGPoint(x: 41.38, y: 6.31),
                             controlPoint1: CGPoint(x: 43.4, y: 6.74),
                             controlPoint2: CGPoint(x: 42.41, y: 6.31))
        bezier6Path.addCurve(to: CGPoint(x: 37.44, y: 10.5),
                             controlPoint1: CGPoint(x: 39.21, y: 6.31),
                             controlPoint2: CGPoint(x: 37.44, y: 8.18))
        bezier6Path.addCurve(to: CGPoint(x: 41.38, y: 14.69),
                             controlPoint1: CGPoint(x: 37.44, y: 12.82),
                             controlPoint2: CGPoint(x: 39.21, y: 14.69))
        bezier6Path.addCurve(to: CGPoint(x: 44.11, y: 13.5),
                             controlPoint1: CGPoint(x: 42.42, y: 14.69),
                             controlPoint2: CGPoint(x: 43.41, y: 14.26))
        bezier6Path.addLine(to: CGPoint(x: 44.11, y: 14.23))
        bezier6Path.addCurve(to: CGPoint(x: 44.34, y: 14.46),
                             controlPoint1: CGPoint(x: 44.11, y: 14.36),
                             controlPoint2: CGPoint(x: 44.21, y: 14.46))
        bezier6Path.addLine(to: CGPoint(x: 45.74, y: 14.46))
        bezier6Path.addCurve(to: CGPoint(x: 45.97, y: 14.23),
                             controlPoint1: CGPoint(x: 45.87, y: 14.46),
                             controlPoint2: CGPoint(x: 45.97, y: 14.35))
        bezier6Path.addLine(to: CGPoint(x: 45.97, y: 6.74))
        bezier6Path.addCurve(to: CGPoint(x: 45.75, y: 6.52),
                             controlPoint1: CGPoint(x: 45.97, y: 6.62),
                             controlPoint2: CGPoint(x: 45.88, y: 6.52))
        bezier6Path.addCurve(to: CGPoint(x: 45.74, y: 6.53),
                             controlPoint1: CGPoint(x: 45.75, y: 6.53),
                             controlPoint2: CGPoint(x: 45.75, y: 6.53))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 44.12, y: 10.53))
        bezier6Path.addCurve(to: CGPoint(x: 41.71, y: 13),
                             controlPoint1: CGPoint(x: 44.11, y: 11.9),
                             controlPoint2: CGPoint(x: 43.03, y: 13))
        bezier6Path.addCurve(to: CGPoint(x: 39.29, y: 10.49),
                             controlPoint1: CGPoint(x: 40.39, y: 13),
                             controlPoint2: CGPoint(x: 39.29, y: 11.88))
        bezier6Path.addCurve(to: CGPoint(x: 41.69, y: 7.97),
                             controlPoint1: CGPoint(x: 39.29, y: 9.1),
                             controlPoint2: CGPoint(x: 40.37, y: 7.97))
        bezier6Path.addCurve(to: CGPoint(x: 44.1, y: 10.45),
                             controlPoint1: CGPoint(x: 43.02, y: 7.97),
                             controlPoint2: CGPoint(x: 44.08, y: 9.08))
        bezier6Path.addLine(to: CGPoint(x: 44.12, y: 10.53))
        bezier6Path.close()
        fillColor.setFill()
        bezier6Path.fill()

        // Bezier #7
        let bezier7Path = UIBezierPath()
        bezier7Path.move(to: CGPoint(x: 41.71, y: 7.98))
        bezier7Path.addCurve(to: CGPoint(x: 39.29, y: 10.49),
                             controlPoint1: CGPoint(x: 40.38, y: 7.98),
                             controlPoint2: CGPoint(x: 39.29, y: 9.1))
        bezier7Path.addCurve(to: CGPoint(x: 41.71, y: 13),
                             controlPoint1: CGPoint(x: 39.29, y: 11.88),
                             controlPoint2: CGPoint(x: 40.37, y: 13))
        bezier7Path.addCurve(to: CGPoint(x: 44.12, y: 10.52),
                             controlPoint1: CGPoint(x: 43.05, y: 13),
                             controlPoint2: CGPoint(x: 44.1, y: 11.89))
        bezier7Path.addLine(to: CGPoint(x: 44.12, y: 10.46))
        bezier7Path.addCurve(to: CGPoint(x: 41.71, y: 7.98),
                             controlPoint1: CGPoint(x: 44.1, y: 9.09),
                             controlPoint2: CGPoint(x: 43.03, y: 7.98))
        bezier7Path.close()
        bezier7Path.move(to: CGPoint(x: 40.55, y: 10.49))
        bezier7Path.addCurve(to: CGPoint(x: 41.72, y: 9.22),
                             controlPoint1: CGPoint(x: 40.55, y: 9.79),
                             controlPoint2: CGPoint(x: 41.07, y: 9.22))
        bezier7Path.addCurve(to: CGPoint(x: 42.89, y: 10.47),
                             controlPoint1: CGPoint(x: 42.36, y: 9.22),
                             controlPoint2: CGPoint(x: 42.86, y: 9.78))
        bezier7Path.addLine(to: CGPoint(x: 42.89, y: 10.51))
        bezier7Path.addCurve(to: CGPoint(x: 41.72, y: 11.75),
                             controlPoint1: CGPoint(x: 42.88, y: 11.19),
                             controlPoint2: CGPoint(x: 42.36, y: 11.75))
        bezier7Path.addCurve(to: CGPoint(x: 40.55, y: 10.49),
                             controlPoint1: CGPoint(x: 41.08, y: 11.75),
                             controlPoint2: CGPoint(x: 40.55, y: 11.19))
        bezier7Path.close()
        fillColor2.setFill()
        bezier7Path.fill()

        // Bezier #8
        let bezier8Path = UIBezierPath()
        bezier8Path.move(to: CGPoint(x: 52.41, y: 6.32))
        bezier8Path.addCurve(to: CGPoint(x: 49.68, y: 7.5),
                             controlPoint1: CGPoint(x: 51.38, y: 6.32),
                             controlPoint2: CGPoint(x: 50.38, y: 6.74))
        bezier8Path.addLine(to: CGPoint(x: 49.68, y: 6.75))
        bezier8Path.addCurve(to: CGPoint(x: 49.45, y: 6.52),
                             controlPoint1: CGPoint(x: 49.68, y: 6.62),
                             controlPoint2: CGPoint(x: 49.58, y: 6.52))
        bezier8Path.addLine(to: CGPoint(x: 48.05, y: 6.52))
        bezier8Path.addCurve(to: CGPoint(x: 47.82, y: 6.75),
                             controlPoint1: CGPoint(x: 47.92, y: 6.52),
                             controlPoint2: CGPoint(x: 47.82, y: 6.63))
        bezier8Path.addLine(to: CGPoint(x: 47.82, y: 17.47))
        bezier8Path.addCurve(to: CGPoint(x: 48.05, y: 17.7),
                             controlPoint1: CGPoint(x: 47.82, y: 17.6),
                             controlPoint2: CGPoint(x: 47.92, y: 17.7))
        bezier8Path.addLine(to: CGPoint(x: 49.45, y: 17.7))
        bezier8Path.addCurve(to: CGPoint(x: 49.68, y: 17.47),
                             controlPoint1: CGPoint(x: 49.58, y: 17.7),
                             controlPoint2: CGPoint(x: 49.68, y: 17.6))
        bezier8Path.addLine(to: CGPoint(x: 49.68, y: 13.5))
        bezier8Path.addCurve(to: CGPoint(x: 52.42, y: 14.68),
                             controlPoint1: CGPoint(x: 50.39, y: 14.25),
                             controlPoint2: CGPoint(x: 51.38, y: 14.68))
        bezier8Path.addCurve(to: CGPoint(x: 56.36, y: 10.49),
                             controlPoint1: CGPoint(x: 54.59, y: 14.68),
                             controlPoint2: CGPoint(x: 56.36, y: 12.81))
        bezier8Path.addCurve(to: CGPoint(x: 52.41, y: 6.32),
                             controlPoint1: CGPoint(x: 56.36, y: 8.17),
                             controlPoint2: CGPoint(x: 54.58, y: 6.32))
        bezier8Path.close()
        bezier8Path.move(to: CGPoint(x: 52.08, y: 13.01))
        bezier8Path.addCurve(to: CGPoint(x: 49.66, y: 10.53),
                             controlPoint1: CGPoint(x: 50.76, y: 13.01),
                             controlPoint2: CGPoint(x: 49.69, y: 11.9))
        bezier8Path.addLine(to: CGPoint(x: 49.66, y: 10.46))
        bezier8Path.addCurve(to: CGPoint(x: 52.06, y: 7.97),
                             controlPoint1: CGPoint(x: 49.68, y: 9.08),
                             controlPoint2: CGPoint(x: 50.75, y: 7.97))
        bezier8Path.addCurve(to: CGPoint(x: 54.47, y: 10.48),
                             controlPoint1: CGPoint(x: 53.38, y: 7.97),
                             controlPoint2: CGPoint(x: 54.47, y: 9.09))
        bezier8Path.addCurve(to: CGPoint(x: 52.08, y: 13.01),
                             controlPoint1: CGPoint(x: 54.47, y: 11.87), controlPoint2: CGPoint(x: 53.4, y: 13))
        bezier8Path.addLine(to: CGPoint(x: 52.08, y: 13.01))
        bezier8Path.close()
        fillColor.setFill()
        bezier8Path.fill()

        // Bezier #9
        let bezier9Path = UIBezierPath()
        bezier9Path.move(to: CGPoint(x: 52.08, y: 7.98))
        bezier9Path.addCurve(to: CGPoint(x: 49.66, y: 10.46),
                             controlPoint1: CGPoint(x: 50.76, y: 7.98),
                             controlPoint2: CGPoint(x: 49.69, y: 9.09))
        bezier9Path.addLine(to: CGPoint(x: 49.66, y: 10.52))
        bezier9Path.addCurve(to: CGPoint(x: 52.08, y: 13),
                             controlPoint1: CGPoint(x: 49.69, y: 11.9),
                             controlPoint2: CGPoint(x: 50.76, y: 13))
        bezier9Path.addCurve(to: CGPoint(x: 54.49, y: 10.49),
                             controlPoint1: CGPoint(x: 53.4, y: 13),
                             controlPoint2: CGPoint(x: 54.49, y: 11.88))
        bezier9Path.addCurve(to: CGPoint(x: 52.08, y: 7.98),
                             controlPoint1: CGPoint(x: 54.49, y: 9.1),
                             controlPoint2: CGPoint(x: 53.4, y: 7.98))
        bezier9Path.close()
        bezier9Path.move(to: CGPoint(x: 52.08, y: 11.76))
        bezier9Path.addCurve(to: CGPoint(x: 50.91, y: 10.51),
                             controlPoint1: CGPoint(x: 51.45, y: 11.76),
                             controlPoint2: CGPoint(x: 50.94, y: 11.2))
        bezier9Path.addLine(to: CGPoint(x: 50.91, y: 10.47))
        bezier9Path.addCurve(to: CGPoint(x: 52.08, y: 9.22),
                             controlPoint1: CGPoint(x: 50.92, y: 9.78),
                             controlPoint2: CGPoint(x: 51.45, y: 9.22))
        bezier9Path.addCurve(to: CGPoint(x: 53.25, y: 10.49),
                             controlPoint1: CGPoint(x: 52.71, y: 9.22),
                             controlPoint2: CGPoint(x: 53.25, y: 9.8))
        bezier9Path.addCurve(to: CGPoint(x: 52.08, y: 11.76),
                             controlPoint1: CGPoint(x: 53.25, y: 11.18),
                             controlPoint2: CGPoint(x: 52.72, y: 11.76))
        bezier9Path.close()
        fillColor2.setFill()
        bezier9Path.fill()

        // Bezier #10
        let bezier10Path = UIBezierPath()
        bezier10Path.move(to: CGPoint(x: 36.08, y: 14.24))
        bezier10Path.addCurve(to: CGPoint(x: 35.85, y: 14.47),
                              controlPoint1: CGPoint(x: 36.08, y: 14.37),
                              controlPoint2: CGPoint(x: 35.98, y: 14.47))
        bezier10Path.addLine(to: CGPoint(x: 34.44, y: 14.47))
        bezier10Path.addCurve(to: CGPoint(x: 34.21, y: 14.24),
                              controlPoint1: CGPoint(x: 34.31, y: 14.47),
                              controlPoint2: CGPoint(x: 34.21, y: 14.36))
        bezier10Path.addLine(to: CGPoint(x: 34.21, y: 9.68))
        bezier10Path.addCurve(to: CGPoint(x: 32.59, y: 7.97),
                              controlPoint1: CGPoint(x: 34.21, y: 8.7),
                              controlPoint2: CGPoint(x: 33.47, y: 7.97))
        bezier10Path.addCurve(to: CGPoint(x: 31, y: 9.59),
                              controlPoint1: CGPoint(x: 31.79, y: 7.97),
                              controlPoint2: CGPoint(x: 31.13, y: 8.67))
        bezier10Path.addLine(to: CGPoint(x: 31.01, y: 14.25))
        bezier10Path.addCurve(to: CGPoint(x: 30.78, y: 14.48),
                              controlPoint1: CGPoint(x: 31.01, y: 14.38),
                              controlPoint2: CGPoint(x: 30.9, y: 14.48))
        bezier10Path.addLine(to: CGPoint(x: 29.37, y: 14.48))
        bezier10Path.addCurve(to: CGPoint(x: 29.14, y: 14.25),
                              controlPoint1: CGPoint(x: 29.24, y: 14.48),
                              controlPoint2: CGPoint(x: 29.14, y: 14.37))
        bezier10Path.addLine(to: CGPoint(x: 29.14, y: 9.68))
        bezier10Path.addCurve(to: CGPoint(x: 27.52, y: 7.97),
                              controlPoint1: CGPoint(x: 29.14, y: 8.7),
                              controlPoint2: CGPoint(x: 28.4, y: 7.97))
        bezier10Path.addCurve(to: CGPoint(x: 25.92, y: 9.77),
                              controlPoint1: CGPoint(x: 26.67, y: 7.97),
                              controlPoint2: CGPoint(x: 25.98, y: 8.76))
        bezier10Path.addLine(to: CGPoint(x: 25.92, y: 14.25))
        bezier10Path.addCurve(to: CGPoint(x: 25.69, y: 14.48),
                              controlPoint1: CGPoint(x: 25.92, y: 14.38),
                              controlPoint2: CGPoint(x: 25.82, y: 14.48))
        bezier10Path.addLine(to: CGPoint(x: 24.29, y: 14.48))
        bezier10Path.addCurve(to: CGPoint(x: 24.06, y: 14.25),
                              controlPoint1: CGPoint(x: 24.16, y: 14.48),
                              controlPoint2: CGPoint(x: 24.06, y: 14.37))
        bezier10Path.addLine(to: CGPoint(x: 24.06, y: 6.74))
        bezier10Path.addCurve(to: CGPoint(x: 24.29, y: 6.52),
                              controlPoint1: CGPoint(x: 24.07, y: 6.61),
                              controlPoint2: CGPoint(x: 24.16, y: 6.52))
        bezier10Path.addLine(to: CGPoint(x: 25.69, y: 6.52))
        bezier10Path.addCurve(to: CGPoint(x: 25.92, y: 6.74),
                              controlPoint1: CGPoint(x: 25.82, y: 6.52),
                              controlPoint2: CGPoint(x: 25.91, y: 6.63))
        bezier10Path.addLine(to: CGPoint(x: 25.92, y: 7.4))
        bezier10Path.addCurve(to: CGPoint(x: 28.08, y: 6.3),
                              controlPoint1: CGPoint(x: 26.42, y: 6.72),
                              controlPoint2: CGPoint(x: 27.22, y: 6.31))
        bezier10Path.addLine(to: CGPoint(x: 28.11, y: 6.3))
        bezier10Path.addCurve(to: CGPoint(x: 30.71, y: 7.85),
                              controlPoint1: CGPoint(x: 29.2, y: 6.3),
                              controlPoint2: CGPoint(x: 30.2, y: 6.9))
        bezier10Path.addCurve(to: CGPoint(x: 33.15, y: 6.29),
                              controlPoint1: CGPoint(x: 31.16, y: 6.9),
                              controlPoint2: CGPoint(x: 32.11, y: 6.3))
        bezier10Path.addCurve(to: CGPoint(x: 36.05, y: 9.07),
                              controlPoint1: CGPoint(x: 34.77, y: 6.29),
                              controlPoint2: CGPoint(x: 36.08, y: 7.54))
        bezier10Path.addLine(to: CGPoint(x: 36.08, y: 14.24))
        bezier10Path.close()
        fillColor.setFill()
        bezier10Path.fill()

        // Bezier #11
        let bezier11Path = UIBezierPath()
        bezier11Path.move(to: CGPoint(x: 84.34, y: 13.59))
        bezier11Path.addLine(to: CGPoint(x: 84.27, y: 13.46))
        bezier11Path.addLine(to: CGPoint(x: 82.31, y: 10.47))
        bezier11Path.addLine(to: CGPoint(x: 84.25, y: 7.52))
        bezier11Path.addCurve(to: CGPoint(x: 83.84, y: 5.5),
                              controlPoint1: CGPoint(x: 84.69, y: 6.85),
                              controlPoint2: CGPoint(x: 84.51, y: 5.96))
        bezier11Path.addCurve(to: CGPoint(x: 83.8, y: 5.49),
                              controlPoint1: CGPoint(x: 83.82, y: 5.5),
                              controlPoint2: CGPoint(x: 83.81, y: 5.5))
        bezier11Path.addCurve(to: CGPoint(x: 83.02, y: 5.27),
                              controlPoint1: CGPoint(x: 83.57, y: 5.34),
                              controlPoint2: CGPoint(x: 83.3, y: 5.27))
        bezier11Path.addLine(to: CGPoint(x: 81.41, y: 5.27))
        bezier11Path.addCurve(to: CGPoint(x: 80.04, y: 6.05),
                              controlPoint1: CGPoint(x: 80.85, y: 5.27),
                              controlPoint2: CGPoint(x: 80.33, y: 5.56))
        bezier11Path.addLine(to: CGPoint(x: 79.72, y: 6.6))
        bezier11Path.addLine(to: CGPoint(x: 79.38, y: 6.04))
        bezier11Path.addCurve(to: CGPoint(x: 78, y: 5.27),
                              controlPoint1: CGPoint(x: 79.09, y: 5.56),
                              controlPoint2: CGPoint(x: 78.57, y: 5.27))
        bezier11Path.addLine(to: CGPoint(x: 76.4, y: 5.27))
        bezier11Path.addCurve(to: CGPoint(x: 75.05, y: 6.19),
                              controlPoint1: CGPoint(x: 75.8, y: 5.27),
                              controlPoint2: CGPoint(x: 75.27, y: 5.64))
        bezier11Path.addCurve(to: CGPoint(x: 67.79, y: 6.64),
                              controlPoint1: CGPoint(x: 72.86, y: 4.53),
                              controlPoint2: CGPoint(x: 69.77, y: 4.72))
        bezier11Path.addCurve(to: CGPoint(x: 66.9, y: 7.78),
                              controlPoint1: CGPoint(x: 67.44, y: 6.98),
                              controlPoint2: CGPoint(x: 67.14, y: 7.36))
        bezier11Path.addCurve(to: CGPoint(x: 62.4, y: 5.06),
                              controlPoint1: CGPoint(x: 66, y: 6.16),
                              controlPoint2: CGPoint(x: 64.32, y: 5.06))
        bezier11Path.addCurve(to: CGPoint(x: 60.92, y: 5.29),
                              controlPoint1: CGPoint(x: 61.9, y: 5.06),
                              controlPoint2: CGPoint(x: 61.39, y: 5.13))
        bezier11Path.addLine(to: CGPoint(x: 60.92, y: 3.51))
        bezier11Path.addCurve(to: CGPoint(x: 59.45, y: 2.03),
                              controlPoint1: CGPoint(x: 60.92, y: 2.69),
                              controlPoint2: CGPoint(x: 60.26, y: 2.03))
        bezier11Path.addLine(to: CGPoint(x: 58.05, y: 2.03))
        bezier11Path.addCurve(to: CGPoint(x: 56.58, y: 3.5),
                              controlPoint1: CGPoint(x: 57.24, y: 2.03),
                              controlPoint2: CGPoint(x: 56.58, y: 2.69))
        bezier11Path.addLine(to: CGPoint(x: 56.58, y: 7.25))
        bezier11Path.addCurve(to: CGPoint(x: 52.41, y: 5.06),
                              controlPoint1: CGPoint(x: 55.63, y: 5.89),
                              controlPoint2: CGPoint(x: 54.08, y: 5.07))
        bezier11Path.addCurve(to: CGPoint(x: 50.29, y: 5.53),
                              controlPoint1: CGPoint(x: 51.67, y: 5.06),
                              controlPoint2: CGPoint(x: 50.95, y: 5.22))
        bezier11Path.addCurve(to: CGPoint(x: 49.45, y: 5.27),
                              controlPoint1: CGPoint(x: 50.05, y: 5.36),
                              controlPoint2: CGPoint(x: 49.75, y: 5.27))
        bezier11Path.addLine(to: CGPoint(x: 48.05, y: 5.27))
        bezier11Path.addCurve(to: CGPoint(x: 46.9, y: 5.83),
                              controlPoint1: CGPoint(x: 47.6, y: 5.27),
                              controlPoint2: CGPoint(x: 47.18, y: 5.48))
        bezier11Path.addCurve(to: CGPoint(x: 46.83, y: 5.75),
                              controlPoint1: CGPoint(x: 46.88, y: 5.8),
                              controlPoint2: CGPoint(x: 46.86, y: 5.78))
        bezier11Path.addCurve(to: CGPoint(x: 45.74, y: 5.28),
                              controlPoint1: CGPoint(x: 46.55, y: 5.45),
                              controlPoint2: CGPoint(x: 46.15, y: 5.28))
        bezier11Path.addLine(to: CGPoint(x: 44.35, y: 5.28))
        bezier11Path.addCurve(to: CGPoint(x: 43.51, y: 5.54),
                              controlPoint1: CGPoint(x: 44.05, y: 5.28),
                              controlPoint2: CGPoint(x: 43.75, y: 5.37))
        bezier11Path.addCurve(to: CGPoint(x: 41.39, y: 5.08),
                              controlPoint1: CGPoint(x: 42.84, y: 5.24),
                              controlPoint2: CGPoint(x: 42.12, y: 5.08))
        bezier11Path.addCurve(to: CGPoint(x: 37.02, y: 7.58),
                              controlPoint1: CGPoint(x: 39.56, y: 5.08),
                              controlPoint2: CGPoint(x: 37.96, y: 6.08))
        bezier11Path.addCurve(to: CGPoint(x: 36.19, y: 6.33),
                              controlPoint1: CGPoint(x: 36.82, y: 7.12),
                              controlPoint2: CGPoint(x: 36.54, y: 6.69))
        bezier11Path.addCurve(to: CGPoint(x: 33.17, y: 5.08),
                              controlPoint1: CGPoint(x: 35.39, y: 5.52),
                              controlPoint2: CGPoint(x: 34.3, y: 5.08))
        bezier11Path.addLine(to: CGPoint(x: 33.16, y: 5.08))
        bezier11Path.addCurve(to: CGPoint(x: 30.7, y: 5.96),
                              controlPoint1: CGPoint(x: 32.27, y: 5.09),
                              controlPoint2: CGPoint(x: 31.41, y: 5.41))
        bezier11Path.addCurve(to: CGPoint(x: 28.13, y: 5.08),
                              controlPoint1: CGPoint(x: 29.96, y: 5.39),
                              controlPoint2: CGPoint(x: 29.06, y: 5.08))
        bezier11Path.addLine(to: CGPoint(x: 28.1, y: 5.08))
        bezier11Path.addCurve(to: CGPoint(x: 27.24, y: 5.19),
                              controlPoint1: CGPoint(x: 27.81, y: 5.08),
                              controlPoint2: CGPoint(x: 27.52, y: 5.11))
        bezier11Path.addCurve(to: CGPoint(x: 26.42, y: 5.47),
                              controlPoint1: CGPoint(x: 26.96, y: 5.25),
                              controlPoint2: CGPoint(x: 26.68, y: 5.35))
        bezier11Path.addCurve(to: CGPoint(x: 25.72, y: 5.29),
                              controlPoint1: CGPoint(x: 26.21, y: 5.35),
                              controlPoint2: CGPoint(x: 25.97, y: 5.29))
        bezier11Path.addLine(to: CGPoint(x: 24.32, y: 5.29))
        bezier11Path.addCurve(to: CGPoint(x: 22.85, y: 6.76),
                              controlPoint1: CGPoint(x: 23.5, y: 5.29),
                              controlPoint2: CGPoint(x: 22.85, y: 5.95))
        bezier11Path.addLine(to: CGPoint(x: 22.85, y: 14.26))
        bezier11Path.addCurve(to: CGPoint(x: 24.32, y: 15.73),
                              controlPoint1: CGPoint(x: 22.85, y: 15.08),
                              controlPoint2: CGPoint(x: 23.51, y: 15.73))
        bezier11Path.addLine(to: CGPoint(x: 25.72, y: 15.73))
        bezier11Path.addCurve(to: CGPoint(x: 27.2, y: 14.25),
                              controlPoint1: CGPoint(x: 26.54, y: 15.73),
                              controlPoint2: CGPoint(x: 27.2, y: 15.07))
        bezier11Path.addLine(to: CGPoint(x: 27.2, y: 14.25))
        bezier11Path.addLine(to: CGPoint(x: 27.2, y: 9.79))
        bezier11Path.addCurve(to: CGPoint(x: 27.56, y: 9.2),
                              controlPoint1: CGPoint(x: 27.23, y: 9.43),
                              controlPoint2: CGPoint(x: 27.43, y: 9.2))
        bezier11Path.addCurve(to: CGPoint(x: 27.94, y: 9.67),
                              controlPoint1: CGPoint(x: 27.74, y: 9.2),
                              controlPoint2: CGPoint(x: 27.94, y: 9.38))
        bezier11Path.addLine(to: CGPoint(x: 27.94, y: 14.24))
        bezier11Path.addCurve(to: CGPoint(x: 29.41, y: 15.71),
                              controlPoint1: CGPoint(x: 27.94, y: 15.06),
                              controlPoint2: CGPoint(x: 28.6, y: 15.71))
        bezier11Path.addLine(to: CGPoint(x: 30.82, y: 15.71))
        bezier11Path.addCurve(to: CGPoint(x: 32.29, y: 14.24),
                              controlPoint1: CGPoint(x: 31.64, y: 15.71),
                              controlPoint2: CGPoint(x: 32.29, y: 15.05))
        bezier11Path.addLine(to: CGPoint(x: 32.28, y: 9.67))
        bezier11Path.addCurve(to: CGPoint(x: 32.63, y: 9.2),
                              controlPoint1: CGPoint(x: 32.34, y: 9.35),
                              controlPoint2: CGPoint(x: 32.53, y: 9.2))
        bezier11Path.addCurve(to: CGPoint(x: 33.01, y: 9.67),
                              controlPoint1: CGPoint(x: 32.81, y: 9.2),
                              controlPoint2: CGPoint(x: 33.01, y: 9.38))
        bezier11Path.addLine(to: CGPoint(x: 33.01, y: 14.24))
        bezier11Path.addCurve(to: CGPoint(x: 34.48, y: 15.71),
                              controlPoint1: CGPoint(x: 33.01, y: 15.06),
                              controlPoint2: CGPoint(x: 33.67, y: 15.71))
        bezier11Path.addLine(to: CGPoint(x: 35.89, y: 15.71))
        bezier11Path.addCurve(to: CGPoint(x: 37.36, y: 14.24),
                              controlPoint1: CGPoint(x: 36.71, y: 15.71),
                              controlPoint2: CGPoint(x: 37.36, y: 15.05))
        bezier11Path.addLine(to: CGPoint(x: 37.36, y: 13.86))
        bezier11Path.addCurve(to: CGPoint(x: 41.42, y: 15.92),
                              controlPoint1: CGPoint(x: 38.32, y: 15.15),
                              controlPoint2: CGPoint(x: 39.82, y: 15.92))
        bezier11Path.addCurve(to: CGPoint(x: 43.54, y: 15.45),
                              controlPoint1: CGPoint(x: 42.16, y: 15.92),
                              controlPoint2: CGPoint(x: 42.88, y: 15.76))
        bezier11Path.addCurve(to: CGPoint(x: 44.38, y: 15.71),
                              controlPoint1: CGPoint(x: 43.78, y: 15.62),
                              controlPoint2: CGPoint(x: 44.08, y: 15.71))
        bezier11Path.addLine(to: CGPoint(x: 45.77, y: 15.71))
        bezier11Path.addCurve(to: CGPoint(x: 46.61, y: 15.45),
                              controlPoint1: CGPoint(x: 46.07, y: 15.71),
                              controlPoint2: CGPoint(x: 46.37, y: 15.62))
        bezier11Path.addLine(to: CGPoint(x: 46.61, y: 17.46))
        bezier11Path.addCurve(to: CGPoint(x: 48.08, y: 18.93),
                              controlPoint1: CGPoint(x: 46.61, y: 18.28),
                              controlPoint2: CGPoint(x: 47.27, y: 18.93))
        bezier11Path.addLine(to: CGPoint(x: 49.48, y: 18.93))
        bezier11Path.addCurve(to: CGPoint(x: 50.95, y: 17.46),
                              controlPoint1: CGPoint(x: 50.3, y: 18.93),
                              controlPoint2: CGPoint(x: 50.95, y: 18.27))
        bezier11Path.addLine(to: CGPoint(x: 50.95, y: 15.69))
        bezier11Path.addCurve(to: CGPoint(x: 52.44, y: 15.91),
                              controlPoint1: CGPoint(x: 51.43, y: 15.84),
                              controlPoint2: CGPoint(x: 51.94, y: 15.92))
        bezier11Path.addCurve(to: CGPoint(x: 56.61, y: 13.71),
                              controlPoint1: CGPoint(x: 54.14, y: 15.91),
                              controlPoint2: CGPoint(x: 55.66, y: 15.04))
        bezier11Path.addLine(to: CGPoint(x: 56.61, y: 14.23))
        bezier11Path.addCurve(to: CGPoint(x: 58.08, y: 15.7),
                              controlPoint1: CGPoint(x: 56.61, y: 15.05),
                              controlPoint2: CGPoint(x: 57.27, y: 15.7))
        bezier11Path.addLine(to: CGPoint(x: 59.48, y: 15.7))
        bezier11Path.addCurve(to: CGPoint(x: 60.32, y: 15.44),
                              controlPoint1: CGPoint(x: 59.78, y: 15.7),
                              controlPoint2: CGPoint(x: 60.08, y: 15.61))
        bezier11Path.addCurve(to: CGPoint(x: 62.44, y: 15.91),
                              controlPoint1: CGPoint(x: 60.98, y: 15.75),
                              controlPoint2: CGPoint(x: 61.71, y: 15.91))
        bezier11Path.addCurve(to: CGPoint(x: 66.93, y: 13.18),
                              controlPoint1: CGPoint(x: 64.36, y: 15.91),
                              controlPoint2: CGPoint(x: 66.04, y: 14.81))
        bezier11Path.addCurve(to: CGPoint(x: 74.51, y: 15.16),
                              controlPoint1: CGPoint(x: 68.47, y: 15.83),
                              controlPoint2: CGPoint(x: 71.88, y: 16.71))
        bezier11Path.addCurve(to: CGPoint(x: 75.04, y: 14.8),
                              controlPoint1: CGPoint(x: 74.69, y: 15.05),
                              controlPoint2: CGPoint(x: 74.87, y: 14.94))
        bezier11Path.addCurve(to: CGPoint(x: 76.39, y: 15.7),
                              controlPoint1: CGPoint(x: 75.26, y: 15.35),
                              controlPoint2: CGPoint(x: 75.8, y: 15.71))
        bezier11Path.addLine(to: CGPoint(x: 78, y: 15.7))
        bezier11Path.addCurve(to: CGPoint(x: 79.37, y: 14.92),
                              controlPoint1: CGPoint(x: 78.56, y: 15.7),
                              controlPoint2: CGPoint(x: 79.08, y: 15.41))
        bezier11Path.addLine(to: CGPoint(x: 79.74, y: 14.31))
        bezier11Path.addLine(to: CGPoint(x: 80.11, y: 14.92))
        bezier11Path.addCurve(to: CGPoint(x: 81.49, y: 15.7),
                              controlPoint1: CGPoint(x: 80.4, y: 15.4),
                              controlPoint2: CGPoint(x: 80.92, y: 15.7))
        bezier11Path.addLine(to: CGPoint(x: 83.09, y: 15.7))
        bezier11Path.addCurve(to: CGPoint(x: 84.54, y: 14.24),
                              controlPoint1: CGPoint(x: 83.9, y: 15.7),
                              controlPoint2: CGPoint(x: 84.55, y: 15.04))
        bezier11Path.addCurve(to: CGPoint(x: 84.34, y: 13.59),
                              controlPoint1: CGPoint(x: 84.49, y: 14.02),
                              controlPoint2: CGPoint(x: 84.44, y: 13.8))
        bezier11Path.addLine(to: CGPoint(x: 84.34, y: 13.59))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 35.86, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 34.45, y: 14.47))
        bezier11Path.addCurve(to: CGPoint(x: 34.22, y: 14.24),
                              controlPoint1: CGPoint(x: 34.32, y: 14.47),
                              controlPoint2: CGPoint(x: 34.22, y: 14.36))
        bezier11Path.addLine(to: CGPoint(x: 34.22, y: 9.68))
        bezier11Path.addCurve(to: CGPoint(x: 32.6, y: 7.97),
                              controlPoint1: CGPoint(x: 34.22, y: 8.7),
                              controlPoint2: CGPoint(x: 33.48, y: 7.97))
        bezier11Path.addCurve(to: CGPoint(x: 31.01, y: 9.59),
                              controlPoint1: CGPoint(x: 31.8, y: 7.97),
                              controlPoint2: CGPoint(x: 31.14, y: 8.67))
        bezier11Path.addLine(to: CGPoint(x: 31.02, y: 14.25))
        bezier11Path.addCurve(to: CGPoint(x: 30.79, y: 14.48),
                              controlPoint1: CGPoint(x: 31.02, y: 14.38),
                              controlPoint2: CGPoint(x: 30.92, y: 14.48))
        bezier11Path.addLine(to: CGPoint(x: 29.38, y: 14.48))
        bezier11Path.addCurve(to: CGPoint(x: 29.15, y: 14.25),
                              controlPoint1: CGPoint(x: 29.25, y: 14.48),
                              controlPoint2: CGPoint(x: 29.15, y: 14.37))
        bezier11Path.addLine(to: CGPoint(x: 29.15, y: 9.68))
        bezier11Path.addCurve(to: CGPoint(x: 27.53, y: 7.97),
                              controlPoint1: CGPoint(x: 29.15, y: 8.7),
                              controlPoint2: CGPoint(x: 28.41, y: 7.97))
        bezier11Path.addCurve(to: CGPoint(x: 25.93, y: 9.77),
                              controlPoint1: CGPoint(x: 26.68, y: 7.97),
                              controlPoint2: CGPoint(x: 25.99, y: 8.76))
        bezier11Path.addLine(to: CGPoint(x: 25.93, y: 14.25))
        bezier11Path.addCurve(to: CGPoint(x: 25.7, y: 14.48),
                              controlPoint1: CGPoint(x: 25.93, y: 14.38),
                              controlPoint2: CGPoint(x: 25.83, y: 14.48))
        bezier11Path.addLine(to: CGPoint(x: 24.3, y: 14.48))
        bezier11Path.addCurve(to: CGPoint(x: 24.07, y: 14.25),
                              controlPoint1: CGPoint(x: 24.17, y: 14.48),
                              controlPoint2: CGPoint(x: 24.07, y: 14.37))
        bezier11Path.addLine(to: CGPoint(x: 24.07, y: 6.74))
        bezier11Path.addCurve(to: CGPoint(x: 24.3, y: 6.52),
                              controlPoint1: CGPoint(x: 24.08, y: 6.61),
                              controlPoint2: CGPoint(x: 24.18, y: 6.52))
        bezier11Path.addLine(to: CGPoint(x: 25.7, y: 6.52))
        bezier11Path.addCurve(to: CGPoint(x: 25.93, y: 6.74),
                              controlPoint1: CGPoint(x: 25.83, y: 6.52), controlPoint2: CGPoint(x: 25.92, y: 6.63))
        bezier11Path.addLine(to: CGPoint(x: 25.93, y: 7.4))
        bezier11Path.addCurve(to: CGPoint(x: 28.09, y: 6.3),
                              controlPoint1: CGPoint(x: 26.43, y: 6.72),
                              controlPoint2: CGPoint(x: 27.23, y: 6.31))
        bezier11Path.addLine(to: CGPoint(x: 28.12, y: 6.3))
        bezier11Path.addCurve(to: CGPoint(x: 30.72, y: 7.85),
                              controlPoint1: CGPoint(x: 29.21, y: 6.3),
                              controlPoint2: CGPoint(x: 30.21, y: 6.9))
        bezier11Path.addCurve(to: CGPoint(x: 33.16, y: 6.29),
                              controlPoint1: CGPoint(x: 31.17, y: 6.9),
                              controlPoint2: CGPoint(x: 32.12, y: 6.3))
        bezier11Path.addCurve(to: CGPoint(x: 36.06, y: 9.07),
                              controlPoint1: CGPoint(x: 34.78, y: 6.29),
                              controlPoint2: CGPoint(x: 36.09, y: 7.54))
        bezier11Path.addLine(to: CGPoint(x: 36.07, y: 14.23))
        bezier11Path.addCurve(to: CGPoint(x: 35.86, y: 14.47),
                              controlPoint1: CGPoint(x: 36.09, y: 14.36),
                              controlPoint2: CGPoint(x: 35.98, y: 14.46))
        bezier11Path.addLine(to: CGPoint(x: 35.86, y: 14.47))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 45.97, y: 14.24))
        bezier11Path.addCurve(to: CGPoint(x: 45.74, y: 14.47),
                              controlPoint1: CGPoint(x: 45.97, y: 14.37),
                              controlPoint2: CGPoint(x: 45.87, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 44.34, y: 14.47))
        bezier11Path.addCurve(to: CGPoint(x: 44.11, y: 14.24),
                              controlPoint1: CGPoint(x: 44.21, y: 14.47),
                              controlPoint2: CGPoint(x: 44.11, y: 14.36))
        bezier11Path.addLine(to: CGPoint(x: 44.11, y: 13.5))
        bezier11Path.addCurve(to: CGPoint(x: 41.39, y: 14.68),
                              controlPoint1: CGPoint(x: 43.41, y: 14.26),
                              controlPoint2: CGPoint(x: 42.42, y: 14.68))
        bezier11Path.addCurve(to: CGPoint(x: 37.45, y: 10.49),
                              controlPoint1: CGPoint(x: 39.22, y: 14.68),
                              controlPoint2: CGPoint(x: 37.45, y: 12.81))
        bezier11Path.addCurve(to: CGPoint(x: 41.39, y: 6.3),
                              controlPoint1: CGPoint(x: 37.45, y: 8.17),
                              controlPoint2: CGPoint(x: 39.22, y: 6.3))
        bezier11Path.addCurve(to: CGPoint(x: 44.12, y: 7.48),
                              controlPoint1: CGPoint(x: 42.42, y: 6.3),
                              controlPoint2: CGPoint(x: 43.41, y: 6.73))
        bezier11Path.addLine(to: CGPoint(x: 44.12, y: 6.74))
        bezier11Path.addCurve(to: CGPoint(x: 44.35, y: 6.51),
                              controlPoint1: CGPoint(x: 44.12, y: 6.61),
                              controlPoint2: CGPoint(x: 44.22, y: 6.51))
        bezier11Path.addLine(to: CGPoint(x: 45.75, y: 6.51))
        bezier11Path.addCurve(to: CGPoint(x: 45.98, y: 6.72),
                              controlPoint1: CGPoint(x: 45.87, y: 6.5),
                              controlPoint2: CGPoint(x: 45.97, y: 6.59))
        bezier11Path.addCurve(to: CGPoint(x: 45.98, y: 6.74),
                              controlPoint1: CGPoint(x: 45.98, y: 6.73),
                              controlPoint2: CGPoint(x: 45.98, y: 6.73))
        bezier11Path.addLine(to: CGPoint(x: 45.98, y: 14.25))
        bezier11Path.addLine(to: CGPoint(x: 45.97, y: 14.25))
        bezier11Path.addLine(to: CGPoint(x: 45.97, y: 14.24))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 52.41, y: 14.67))
        bezier11Path.addCurve(to: CGPoint(x: 49.68, y: 13.49),
                              controlPoint1: CGPoint(x: 51.38, y: 14.67),
                              controlPoint2: CGPoint(x: 50.39, y: 14.24))
        bezier11Path.addLine(to: CGPoint(x: 49.68, y: 17.46))
        bezier11Path.addCurve(to: CGPoint(x: 49.45, y: 17.69),
                              controlPoint1: CGPoint(x: 49.68, y: 17.59),
                              controlPoint2: CGPoint(x: 49.58, y: 17.69))
        bezier11Path.addLine(to: CGPoint(x: 48.05, y: 17.69))
        bezier11Path.addCurve(to: CGPoint(x: 47.82, y: 17.46),
                              controlPoint1: CGPoint(x: 47.92, y: 17.69),
                              controlPoint2: CGPoint(x: 47.82, y: 17.59))
        bezier11Path.addLine(to: CGPoint(x: 47.82, y: 6.75))
        bezier11Path.addCurve(to: CGPoint(x: 48.05, y: 6.53),
                              controlPoint1: CGPoint(x: 47.82, y: 6.62),
                              controlPoint2: CGPoint(x: 47.92, y: 6.53))
        bezier11Path.addLine(to: CGPoint(x: 49.45, y: 6.53))
        bezier11Path.addCurve(to: CGPoint(x: 49.68, y: 6.76),
                              controlPoint1: CGPoint(x: 49.58, y: 6.53),
                              controlPoint2: CGPoint(x: 49.68, y: 6.64))
        bezier11Path.addLine(to: CGPoint(x: 49.68, y: 7.49))
        bezier11Path.addCurve(to: CGPoint(x: 52.41, y: 6.31),
                              controlPoint1: CGPoint(x: 50.39, y: 6.73),
                              controlPoint2: CGPoint(x: 51.38, y: 6.31))
        bezier11Path.addCurve(to: CGPoint(x: 56.35, y: 10.49),
                              controlPoint1: CGPoint(x: 54.58, y: 6.31),
                              controlPoint2: CGPoint(x: 56.35, y: 8.17))
        bezier11Path.addCurve(to: CGPoint(x: 52.41, y: 14.67),
                              controlPoint1: CGPoint(x: 56.35, y: 12.81),
                              controlPoint2: CGPoint(x: 54.58, y: 14.67))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 66.24, y: 11.39))
        bezier11Path.addCurve(to: CGPoint(x: 62.4, y: 14.68),
                              controlPoint1: CGPoint(x: 65.85, y: 13.26),
                              controlPoint2: CGPoint(x: 64.28, y: 14.68))
        bezier11Path.addCurve(to: CGPoint(x: 59.67, y: 13.5),
                              controlPoint1: CGPoint(x: 61.37, y: 14.68),
                              controlPoint2: CGPoint(x: 60.38, y: 14.25))
        bezier11Path.addLine(to: CGPoint(x: 59.67, y: 14.23))
        bezier11Path.addCurve(to: CGPoint(x: 59.44, y: 14.46),
                              controlPoint1: CGPoint(x: 59.67, y: 14.36),
                              controlPoint2: CGPoint(x: 59.57, y: 14.46))
        bezier11Path.addLine(to: CGPoint(x: 58.04, y: 14.46))
        bezier11Path.addCurve(to: CGPoint(x: 57.81, y: 14.23),
                              controlPoint1: CGPoint(x: 57.91, y: 14.46),
                              controlPoint2: CGPoint(x: 57.81, y: 14.35))
        bezier11Path.addLine(to: CGPoint(x: 57.81, y: 3.51))
        bezier11Path.addCurve(to: CGPoint(x: 58.04, y: 3.28),
                              controlPoint1: CGPoint(x: 57.81, y: 3.38),
                              controlPoint2: CGPoint(x: 57.91, y: 3.28))
        bezier11Path.addLine(to: CGPoint(x: 59.44, y: 3.28))
        bezier11Path.addCurve(to: CGPoint(x: 59.67, y: 3.51),
                              controlPoint1: CGPoint(x: 59.57, y: 3.28),
                              controlPoint2: CGPoint(x: 59.67, y: 3.39))
        bezier11Path.addLine(to: CGPoint(x: 59.67, y: 7.48))
        bezier11Path.addCurve(to: CGPoint(x: 62.4, y: 6.31),
                              controlPoint1: CGPoint(x: 60.38, y: 6.73),
                              controlPoint2: CGPoint(x: 61.37, y: 6.3))
        bezier11Path.addCurve(to: CGPoint(x: 66.24, y: 9.59),
                              controlPoint1: CGPoint(x: 64.28, y: 6.31),
                              controlPoint2: CGPoint(x: 65.85, y: 7.71))
        bezier11Path.addCurve(to: CGPoint(x: 66.24, y: 11.39),
                              controlPoint1: CGPoint(x: 66.37, y: 10.19),
                              controlPoint2: CGPoint(x: 66.37, y: 10.8))
        bezier11Path.addLine(to: CGPoint(x: 66.24, y: 11.39))
        bezier11Path.addLine(to: CGPoint(x: 66.24, y: 11.39))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 71.67, y: 14.68))
        bezier11Path.addCurve(to: CGPoint(x: 67.5, y: 11.38),
                              controlPoint1: CGPoint(x: 69.67, y: 14.69),
                              controlPoint2: CGPoint(x: 67.94, y: 13.33))
        bezier11Path.addCurve(to: CGPoint(x: 67.5, y: 9.61),
                              controlPoint1: CGPoint(x: 67.37, y: 10.79),
                              controlPoint2: CGPoint(x: 67.37, y: 10.19))
        bezier11Path.addCurve(to: CGPoint(x: 71.67, y: 6.31),
                              controlPoint1: CGPoint(x: 67.94, y: 7.67),
                              controlPoint2: CGPoint(x: 69.67, y: 6.3))
        bezier11Path.addCurve(to: CGPoint(x: 75.93, y: 10.5),
                              controlPoint1: CGPoint(x: 74.03, y: 6.31),
                              controlPoint2: CGPoint(x: 75.93, y: 8.18))
        bezier11Path.addCurve(to: CGPoint(x: 71.67, y: 14.68),
                              controlPoint1: CGPoint(x: 75.93, y: 12.82),
                              controlPoint2: CGPoint(x: 74.03, y: 14.68))
        bezier11Path.addLine(to: CGPoint(x: 71.67, y: 14.68))
        bezier11Path.close()
        bezier11Path.move(to: CGPoint(x: 83.04, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 81.43, y: 14.47))
        bezier11Path.addCurve(to: CGPoint(x: 81.13, y: 14.3),
                              controlPoint1: CGPoint(x: 81.3, y: 14.47),
                              controlPoint2: CGPoint(x: 81.19, y: 14.41))
        bezier11Path.addLine(to: CGPoint(x: 79.69, y: 11.91))
        bezier11Path.addLine(to: CGPoint(x: 78.25, y: 14.3))
        bezier11Path.addCurve(to: CGPoint(x: 77.95, y: 14.47),
                              controlPoint1: CGPoint(x: 78.19, y: 14.41),
                              controlPoint2: CGPoint(x: 78.07, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 76.34, y: 14.47))
        bezier11Path.addCurve(to: CGPoint(x: 76.22, y: 14.44),
                              controlPoint1: CGPoint(x: 76.3, y: 14.47),
                              controlPoint2: CGPoint(x: 76.26, y: 14.46))
        bezier11Path.addCurve(to: CGPoint(x: 76.16, y: 14.16),
                              controlPoint1: CGPoint(x: 76.13, y: 14.38),
                              controlPoint2: CGPoint(x: 76.09, y: 14.25))
        bezier11Path.addLine(to: CGPoint(x: 76.16, y: 14.16))
        bezier11Path.addLine(to: CGPoint(x: 78.59, y: 10.48))
        bezier11Path.addLine(to: CGPoint(x: 76.2, y: 6.84))
        bezier11Path.addCurve(to: CGPoint(x: 76.17, y: 6.72),
                              controlPoint1: CGPoint(x: 76.18, y: 6.81),
                              controlPoint2: CGPoint(x: 76.17, y: 6.77))
        bezier11Path.addCurve(to: CGPoint(x: 76.38, y: 6.51),
                              controlPoint1: CGPoint(x: 76.17, y: 6.6),
                              controlPoint2: CGPoint(x: 76.26, y: 6.51))
        bezier11Path.addLine(to: CGPoint(x: 77.99, y: 6.51))
        bezier11Path.addCurve(to: CGPoint(x: 78.29, y: 6.68),
                              controlPoint1: CGPoint(x: 78.12, y: 6.51),
                              controlPoint2: CGPoint(x: 78.23, y: 6.57))
        bezier11Path.addLine(to: CGPoint(x: 79.7, y: 9.04))
        bezier11Path.addLine(to: CGPoint(x: 81.11, y: 6.68))
        bezier11Path.addCurve(to: CGPoint(x: 81.41, y: 6.51),
                              controlPoint1: CGPoint(x: 81.17, y: 6.57),
                              controlPoint2: CGPoint(x: 81.29, y: 6.51))
        bezier11Path.addLine(to: CGPoint(x: 83.02, y: 6.51))
        bezier11Path.addCurve(to: CGPoint(x: 83.14, y: 6.54),
                              controlPoint1: CGPoint(x: 83.06, y: 6.51),
                              controlPoint2: CGPoint(x: 83.1, y: 6.52))
        bezier11Path.addCurve(to: CGPoint(x: 83.2, y: 6.82),
                              controlPoint1: CGPoint(x: 83.23, y: 6.6),
                              controlPoint2: CGPoint(x: 83.27, y: 6.73))
        bezier11Path.addLine(to: CGPoint(x: 83.2, y: 6.82))
        bezier11Path.addLine(to: CGPoint(x: 80.82, y: 10.46))
        bezier11Path.addLine(to: CGPoint(x: 83.25, y: 14.13))
        bezier11Path.addCurve(to: CGPoint(x: 83.28, y: 14.25),
                              controlPoint1: CGPoint(x: 83.27, y: 14.16),
                              controlPoint2: CGPoint(x: 83.28, y: 14.2))
        bezier11Path.addCurve(to: CGPoint(x: 83.04, y: 14.47),
                              controlPoint1: CGPoint(x: 83.25, y: 14.38),
                              controlPoint2: CGPoint(x: 83.16, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 83.04, y: 14.47))
        bezier11Path.addLine(to: CGPoint(x: 83.04, y: 14.47))
        bezier11Path.close()
        fillColor2.setFill()
        bezier11Path.fill()
    }

    internal enum ResizingBehavior: Int {
        case aspectFit  // The content is proportionally resized to fit into the target rectangle.
        case aspectFill // The content is proportionally resized to completely fill the target rectangle.
        case stretch    // The content is stretched to match the entire target rectangle.
        case center     // The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}

// swiftlint:disable:this file_length
