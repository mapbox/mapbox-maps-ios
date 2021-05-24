
// This file is generated.
import Foundation
import Turf

public struct PolygonAnnotation: Hashable {

    // Identifier for this annotation
    public let id: String

    // The feature backing this annotation
    internal var feature: Turf.Feature

    public init(id: String = UUID().uuidString, polygon: Turf.Polygon) {
        self.id = id
        self.feature = Turf.Feature(polygon)
        self.feature.properties = ["id": id]
    }
    
    public init(id: String = UUID().uuidString, polygons: Turf.MultiPolygon) {
        self.id = id
        self.feature = Turf.Feature(polygons)
        self.feature.properties = ["id": id]
    }

    // MARK:- Properties -

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(fillSortKey)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["fill-sort-key"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolygonAnnotation.fillSortKey")
            }
        }
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    public var fillColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(fillColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["fill-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolygonAnnotation.fillColor")
            }
        }
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    public var fillOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(fillOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["fill-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolygonAnnotation.fillOpacity")
            }
        }
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(fillOutlineColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["fill-outline-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolygonAnnotation.fillOutlineColor")
            }
        }
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String? {
        didSet {
            do {
                let data = try JSONEncoder().encode(fillPattern)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["fill-pattern"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolygonAnnotation.fillPattern")
            }
        }
    }

    // MARK:- Hashable -

    public static func == (lhs: PolygonAnnotation, rhs: PolygonAnnotation) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }   
}

// End of generated file.