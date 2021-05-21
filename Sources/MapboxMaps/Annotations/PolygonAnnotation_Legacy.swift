import CoreLocation
import Foundation
import UIKit
import Turf

/**
 Marks a region of coordinates on map, representing a polygon shape.
 */
public struct PolygonAnnotation_Legacy: Annotation_Legacy {

    // MARK: - Public properties

    /**
     Uniquely identifies the polygon annotation.
     */
    public private(set) var identifier: String

    /**
     The type of the annotation - in this case, a polygon.
     */
    public private(set) var type: AnnotationType_Legacy = .polygon

    /**
     The text string containing the polygon's title. If the value is defined,
     the map shows an the polygon's title near the polygon.
     */
    public var title: String?

    /**
     Whether or not the polygon has been selected, either via a tap gesture
     or programmatically.
     */
    public var isSelected: Bool = false

    // MARK: - Internal properties

    /**
    The coordinates belonging to the polygon.
     */
    private(set) public var coordinates: [CLLocationCoordinate2D]

    /**
     An optional array containing arrays that represent holes within
     the polygon.
     */
    private(set) public var interiorPolygons: [[CLLocationCoordinate2D]]?

    /**
     The optional userInfo associated with the polygon annotation.
     */
    public var userInfo: [String: Any]?

    // MARK: - Initialization

    /**
     Creates a new `PolygonAnnotation` initialized with given coordinates.

     - Parameter coordinates: Coordinates representing the shape of the polygon.
     - Returns: `PolygonAnnotation` instance initialized with a given set of coordinates.

     - Note: This method does make the annotation visible.
             Use AnnotationManager.addAnnotation(_ annotation:) to render it on
             the map view.
     */
    public init(coordinates: [CLLocationCoordinate2D], interiorPolygons: [[CLLocationCoordinate2D]]? = nil) {
        identifier = UUID().uuidString
        self.coordinates = coordinates
        self.interiorPolygons = interiorPolygons
    }
}

extension PolygonAnnotation_Legacy: Equatable {
    public static func == (lhs: PolygonAnnotation_Legacy, rhs: PolygonAnnotation_Legacy) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
