import UIKit
@_implementationOnly import MapboxCommon_Private

extension PointAnnotation {
    public enum Image: Hashable {
        case `default`
        case custom(image: UIImage, name: String)

        var name: String {
            switch self {
            case .default:
                return "com.mapbox.maps.annotations.point.image.default"
            case .custom(image: _, name: let name):
                return name
            }
        }
    }
}

extension PointAnnotationManager {

    func addImageToStyleIfNeeded(style: Style) {
        let pointAnnotationImages = Set(annotations.compactMap(\.image))
        for pointAnnotationImage in pointAnnotationImages {
            do {
                let image = style.image(withId: pointAnnotationImage.name)

                if image == nil { // If image not found, then add the image to  the style
                    switch pointAnnotationImage {

                    case .default: // Add the default image if not added already
                        try style.addImage(Self.defaultMarker,
                                           id: pointAnnotationImage.name,
                                           stretchX: [],
                                           stretchY: [],
                                           content: nil)

                    case .custom(image: let image, name: let name): // Add this custom image
                        try style.addImage(image,
                                           id: name,
                                           stretchX: [],
                                           stretchY: [],
                                           content: nil)
                    }
                }
            } catch {
                Log.warning(
                    forMessage: "Could not add image to style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
    }

    internal static var defaultSize: CGSize {
        CGSize(width: 20, height: 32)
    }

    //swiftlint:disable function_body_length
    /// Returns the default red pin image, used if no custom image is specified.
    internal static var defaultMarker: UIImage {
        UIGraphicsBeginImageContextWithOptions(defaultSize,
                                               false,
                                               0)
        defer { UIGraphicsEndImageContext() }

        // Color Declarations
        let innerOvalFillColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let shadowFillColor = #colorLiteral(red: 0.149, green: 0.149, blue: 0.149, alpha: 0.2)
        let mainFillColor = #colorLiteral(red: 0.973, green: 0.302, blue: 0.302, alpha: 1)
        let outerStrokeColor = #colorLiteral(red: 0.584, green: 0.071, blue: 0.071, alpha: 1)
        let innerOvalStrokeColor = #colorLiteral(red: 0.486, green: 0.145, blue: 0.145, alpha: 1)

        // Shadow Oval Drawing
        let shadowOvalPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 22, width: 18, height: 10))
        shadowFillColor.setFill()
        shadowOvalPath.fill()

        // Pin Bezier Drawing
        let pinBezierPath = UIBezierPath()
        pinBezierPath.move(to: CGPoint(x: 19.5, y: 10.4))
        pinBezierPath.addCurve(to: CGPoint(x: 10, y: 27.5),
                               controlPoint1: CGPoint(x: 19.5, y: 16.7),
                               controlPoint2: CGPoint(x: 10, y: 27.5))
        pinBezierPath.addCurve(to: CGPoint(x: 0.5, y: 10.4),
                               controlPoint1: CGPoint(x: 10, y: 27.5),
                               controlPoint2: CGPoint(x: 0.5, y: 16.6))
        pinBezierPath.addCurve(to: CGPoint(x: 10, y: 0.5),
                               controlPoint1: CGPoint(x: 0.5, y: 4.9),
                               controlPoint2: CGPoint(x: 4.8, y: 0.5))
        pinBezierPath.addCurve(to: CGPoint(x: 19.5, y: 10.4),
                               controlPoint1: CGPoint(x: 15.2, y: 0.5),
                               controlPoint2: CGPoint(x: 19.5, y: 4.9))
        pinBezierPath.close()
        mainFillColor.setFill()
        pinBezierPath.fill()

        // Outer Pin Border Bezier Drawing
        let outerPinBorderBezierPath = UIBezierPath()
        outerPinBorderBezierPath.move(to: CGPoint(x: 19.5, y: 10.4))
        outerPinBorderBezierPath.addCurve(to: CGPoint(x: 10, y: 27.5),
                                          controlPoint1: CGPoint(x: 19.5, y: 16.7),
                                          controlPoint2: CGPoint(x: 10, y: 27.5))
        outerPinBorderBezierPath.addCurve(to: CGPoint(x: 0.5, y: 10.4),
                                          controlPoint1: CGPoint(x: 10, y: 27.5),
                                          controlPoint2: CGPoint(x: 0.5, y: 16.6))
        outerPinBorderBezierPath.addCurve(to: CGPoint(x: 10, y: 0.5),
                                          controlPoint1: CGPoint(x: 0.5, y: 4.9),
                                          controlPoint2: CGPoint(x: 4.8, y: 0.5))
        outerPinBorderBezierPath.addCurve(to: CGPoint(x: 19.5, y: 10.4),
                                          controlPoint1: CGPoint(x: 15.2, y: 0.5),
                                          controlPoint2: CGPoint(x: 19.5, y: 4.9))
        outerPinBorderBezierPath.close()
        outerStrokeColor.setStroke()
        outerPinBorderBezierPath.lineWidth = 1.02
        outerPinBorderBezierPath.lineCapStyle = .round
        outerPinBorderBezierPath.lineJoinStyle = .round
        outerPinBorderBezierPath.stroke()

        // Inner Pin Circle Drawing
        let innerPinCirclePath = UIBezierPath(ovalIn: CGRect(x: 6.2, y: 6.2, width: 7.6, height: 7.6))
        innerOvalFillColor.setFill()
        innerPinCirclePath.fill()

        // Inner Pin Border Oval Drawing
        let innerPinBorderOvalPath = UIBezierPath(ovalIn: CGRect(x: 6.2, y: 6.2, width: 7.6, height: 7.6))
        innerOvalStrokeColor.setStroke()
        innerPinBorderOvalPath.lineWidth = 1
        innerPinBorderOvalPath.stroke()

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return UIImage()
        }

        return image
    }
}
