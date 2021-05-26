// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct PolygonAnnotation: Annotation {

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

    public var type: AnnotationType = .polygon

    /// Create a polygon annotation with a `Turf.Polygon` and an optional identifier.
    public init(id: String = UUID().uuidString, polygon: Turf.Polygon) {
        self.id = id
        self.feature = Turf.Feature(polygon)
        self.feature.properties = ["annotation-id": id]
    }
    
    /// Create a polygon annotation with a `Turf.MultiPolygon` and an optional identifier.
    public init(id: String = UUID().uuidString, polygons: Turf.MultiPolygon) {
        self.id = id
        self.feature = Turf.Feature(polygons)
        self.feature.properties = ["annotation-id": id]
    }

    // MARK: - Properties -

    /// Set of used data driven properties
    internal var dataDrivenPropertiesUsedSet: Set<String> = []

    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double? {
        didSet {
            feature.properties?["fill-sort-key"] = fillSortKey 
            if fillSortKey != nil {
                dataDrivenPropertiesUsedSet.insert("fill-sort-key")
            }
        }
    }
    
    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    public var fillColor: ColorRepresentable? {
        didSet {
            feature.properties?["fill-color"] = fillColor?.rgbaDescription 
            if fillColor != nil {
                dataDrivenPropertiesUsedSet.insert("fill-color")
            }
        }
    }
    
    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    public var fillOpacity: Double? {
        didSet {
            feature.properties?["fill-opacity"] = fillOpacity 
            if fillOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("fill-opacity")
            }
        }
    }
    
    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: ColorRepresentable? {
        didSet {
            feature.properties?["fill-outline-color"] = fillOutlineColor?.rgbaDescription 
            if fillOutlineColor != nil {
                dataDrivenPropertiesUsedSet.insert("fill-outline-color")
            }
        }
    }
    
    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String? {
        didSet {
            feature.properties?["fill-pattern"] = fillPattern 
            if fillPattern != nil {
                dataDrivenPropertiesUsedSet.insert("fill-pattern")
            }
        }
    }

}

// End of generated file.
// swiftlint:enable all