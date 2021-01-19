import CoreLocation
import Foundation
import UIKit
import Turf

/**
 Marks a single coordinate on the map with a customizable icon.
 By default, this is an image of a red pin.
 */
public struct PointAnnotation: Annotation {

    // MARK: - Public properties

    /**
     Uniquely identifies the annotation.
     */
    public private(set) var identifier: String

    /**
     The type of the annotation - in this case, a point.
     */
    public private(set) var type: AnnotationType = .point

    /**
     The text string containing the annotation's title. If the value is defined,
     the map shows an the annotation's title near the annotation.
     */
    public var title: String?

    /**
     Whether or not the annotation has been selected, either via a tap gesture
     or programmatically.
     */
    public var isSelected: Bool = false

    /**
     Controls whether or not the user can drag the annotation across the map.
     */
    public var isDraggable: Bool = false

    /**
     The image containing a annotation's icon to show on the map. If the value
     is `nil`, then a red pin image is used, representing the default point
     annotation icon image.
     */
    public var image: UIImage?

    /**
     The center coordinate of the annotation.

     The annotation is rendered on the map at this location.
     */
    public private(set) var coordinate: CLLocationCoordinate2D

    /**
     The optional properties associated with the point annotation.
     */
    public var properties: [String: Any]?

    // MARK: - Internal properties

    internal let defaultIconSize = CGSize(width: 20, height: 32)
    internal let defaultIconImageIdentifier = "com.mapbox.AnnotationManager.DefaultIconImage"

    // MARK: - Initialization

    /**
     Creates a new `Annotation` initialized with a given coordinate.

     - Parameter coordinate: The center coordinate of the annotation.
     - Returns: `Annotation` instance initialized with a given coordinate.

     - Note: This method does make the annotation visible.
             Use AnnotationManager.addAnnotation(_ annotation:) to render it on
             the map view.
     */
    public init(coordinate: CLLocationCoordinate2D, image: UIImage? = nil) {
        self.identifier = UUID().uuidString
        self.coordinate = coordinate
        self.image = image

        if image != nil {
            self.properties = ["icon-image": identifier]
        } else {
            self.properties = ["icon-image": defaultIconImageIdentifier]
        }
    }

    // MARK: - Private functions

    /**
     Returns the default red pin image, used if no custom image is specified.
     */
    //swiftlint:disable function_body_length
    public func defaultAnnotationImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(defaultIconSize,
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

extension PointAnnotation: Equatable {
    public static func == (lhs: PointAnnotation, rhs: PointAnnotation) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
