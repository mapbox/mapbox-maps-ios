// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct CircleAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The feature backing this annotation
    public internal(set) var feature: Turf.Feature

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? { 
        didSet {
            feature.properties?["userInfo"] = userInfo
        }
    }


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
        get {
            return feature.properties?["circle-sort-key"] as? Double 
        }
        set {
            feature.properties?["circle-sort-key"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-sort-key")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-sort-key")
            }
        }
    }
    
    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
    public var circleBlur: Double? {
        get {
            return feature.properties?["circle-blur"] as? Double 
        }
        set {
            feature.properties?["circle-blur"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-blur")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-blur")
            }
        }
    }
    
    /// The fill color of the circle.
    public var circleColor: ColorRepresentable? {
        get {
            return feature.properties?["circle-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["circle-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-color")
            }
        }
    }
    
    /// The opacity at which the circle will be drawn.
    public var circleOpacity: Double? {
        get {
            return feature.properties?["circle-opacity"] as? Double 
        }
        set {
            feature.properties?["circle-opacity"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-opacity")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-opacity")
            }
        }
    }
    
    /// Circle radius.
    public var circleRadius: Double? {
        get {
            return feature.properties?["circle-radius"] as? Double 
        }
        set {
            feature.properties?["circle-radius"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-radius")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-radius")
            }
        }
    }
    
    /// The stroke color of the circle.
    public var circleStrokeColor: ColorRepresentable? {
        get {
            return feature.properties?["circle-stroke-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["circle-stroke-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-stroke-color")
            }
        }
    }
    
    /// The opacity of the circle's stroke.
    public var circleStrokeOpacity: Double? {
        get {
            return feature.properties?["circle-stroke-opacity"] as? Double 
        }
        set {
            feature.properties?["circle-stroke-opacity"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-opacity")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-stroke-opacity")
            }
        }
    }
    
    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    public var circleStrokeWidth: Double? {
        get {
            return feature.properties?["circle-stroke-width"] as? Double 
        }
        set {
            feature.properties?["circle-stroke-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("circle-stroke-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("circle-stroke-width")
            }
        }
    }

}

// End of generated file.
// swiftlint:enable all