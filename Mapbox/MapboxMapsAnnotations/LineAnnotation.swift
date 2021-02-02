import CoreLocation
import Foundation
import UIKit
import Turf

/**
 Marks a series of coordinates map, representing a line shape.
 */
public struct LineAnnotation: Annotation {

    // MARK: - Public properties

    /**
     Uniquely identifies the annotation.
     */
    public private(set) var identifier: String

    /**
     The type of the annotation - in this case, a line.
     */
    public private(set) var type: AnnotationType = .line

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

    // MARK: - Internal properties

    /**
     The center coordinate of the annotation.

     The annotation is rendered on the map at this location.
     */
    private(set) public var coordinates: [CLLocationCoordinate2D]

    /**
     The optional properties associated with the line annotation.
     */
    private(set) public var properties: [String: Any]?

    // MARK: - Initialization

    /**
     Creates a new `Annotation` initialized with a given coordinate.

     - Parameter coordinate: The center coordinate of the annotation.
     - Returns: `Annotation` instance initialized with a given coordinate.

     - Note: This method does make the annotation visible.
             Use AnnotationManager.addAnnotation(_ annotation:) to render it on
             the map view.
     */
    public init(coordinates: [CLLocationCoordinate2D]) {
        self.identifier = UUID().uuidString
        self.coordinates = coordinates
    }
}

extension LineAnnotation: Equatable {
    public static func == (lhs: LineAnnotation, rhs: LineAnnotation) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
