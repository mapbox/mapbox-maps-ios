import CoreLocation
import Foundation
import UIKit
import Turf

/**
 Marks a region of coordinates on map, representing a polygon shape.
 */
public struct PolygonAnnotation: Annotation {

    // MARK: - Public properties

    /**
     Uniquely identifies the polygon annotation.
     */
    public private(set) var identifier: String

    /**
     The type of the annotation - in this case, a polygon.
     */
    public private(set) var type: AnnotationType = .polygon

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

    /**
     The optional properties associated with the polygon annotation.
     */
    public var properties: [String: Any]?

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
        self.identifier = UUID().uuidString
        self.coordinates = coordinates
        self.interiorPolygons = interiorPolygons
    }
}

extension PolygonAnnotation: Equatable {
    public static func == (lhs: PolygonAnnotation, rhs: PolygonAnnotation) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
