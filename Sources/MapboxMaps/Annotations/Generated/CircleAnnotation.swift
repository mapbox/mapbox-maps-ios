// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct CircleAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The feature backing this annotation
    public internal(set) var feature: Turf.Feature
    
    /// A Boolean value that indicates whether an annotation is selected, either
    /// programmatically or via user-interactions.
    public var isSelected: Bool = false { 
        didSet {
            feature.properties?["is-selected"] = isSelected
        }
    }

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? { 
        didSet {
            feature.properties?["userInfo"] = userInfo
        }
    }

    public var type: AnnotationType = .circle

    /// Create a circle annotation with a `Turf.Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.feature = Turf.Feature(point)
        self.feature.properties = ["annotation-id": id]
    }

    /// Create a circle annotation with a center coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - coordinate: Coordinate where this circle annotation should be centered
    public init(id: String = UUID().uuidString, centerCoordinate: CLLocationCoordinate2D) {
        let point = Turf.Point(centerCoordinate)
        self.init(id: id, point: point)
    }

    // MARK: - Properties -

    /// Set of used data driven properties
    internal var dataDrivenPropertiesUsedSet: Set<String> = []

    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Double? {
        didSet {
            feature.properties?["circle-sort-key"] = circleSortKey 
            if circleSortKey != nil {
                dataDrivenPropertiesUsedSet.insert("circle-sort-key")
            }
        }
    }
    
    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
    public var circleBlur: Double? {
        didSet {
            feature.properties?["circle-blur"] = circleBlur 
            if circleBlur != nil {
                dataDrivenPropertiesUsedSet.insert("circle-blur")
            }
        }
    }
    
    /// The fill color of the circle.
    public var circleColor: ColorRepresentable? {
        didSet {
            feature.properties?["circle-color"] = circleColor?.rgbaDescription 
            if circleColor != nil {
                dataDrivenPropertiesUsedSet.insert("circle-color")
            }
        }
    }
    
    /// The opacity at which the circle will be drawn.
    public var circleOpacity: Double? {
        didSet {
            feature.properties?["circle-opacity"] = circleOpacity 
            if circleOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("circle-opacity")
            }
        }
    }
    
    /// Circle radius.
    public var circleRadius: Double? {
        didSet {
            feature.properties?["circle-radius"] = circleRadius 
            if circleRadius != nil {
                dataDrivenPropertiesUsedSet.insert("circle-radius")
            }
        }
    }
    
    /// The stroke color of the circle.
    public var circleStrokeColor: ColorRepresentable? {
        didSet {
            feature.properties?["circle-stroke-color"] = circleStrokeColor?.rgbaDescription 
            if circleStrokeColor != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-color")
            }
        }
    }
    
    /// The opacity of the circle's stroke.
    public var circleStrokeOpacity: Double? {
        didSet {
            feature.properties?["circle-stroke-opacity"] = circleStrokeOpacity 
            if circleStrokeOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-opacity")
            }
        }
    }
    
    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    public var circleStrokeWidth: Double? {
        didSet {
            feature.properties?["circle-stroke-width"] = circleStrokeWidth 
            if circleStrokeWidth != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-width")
            }
        }
    }

}

// End of generated file.
// swiftlint:enable all