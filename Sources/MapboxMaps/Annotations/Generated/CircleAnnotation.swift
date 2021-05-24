
// This file is generated.
import Foundation
import Turf

public struct CircleAnnotation: Hashable {

    // Identifier for this annotation
    public let id: String

    // The feature backing this annotation
    internal var feature: Turf.Feature

    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.feature = Turf.Feature(point)
        self.feature.properties = ["id": id]
    }

    // MARK:- Properties -

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleSortKey)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-sort-key"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleSortKey")
            }
        }
    }

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
    public var circleBlur: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleBlur)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-blur"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleBlur")
            }
        }
    }

    /// The fill color of the circle.
    public var circleColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleColor")
            }
        }
    }

    /// The opacity at which the circle will be drawn.
    public var circleOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleOpacity")
            }
        }
    }

    /// Circle radius.
    public var circleRadius: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleRadius)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-radius"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleRadius")
            }
        }
    }

    /// The stroke color of the circle.
    public var circleStrokeColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleStrokeColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-stroke-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleStrokeColor")
            }
        }
    }

    /// The opacity of the circle's stroke.
    public var circleStrokeOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleStrokeOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-stroke-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleStrokeOpacity")
            }
        }
    }

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    public var circleStrokeWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(circleStrokeWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["circle-stroke-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: CircleAnnotation.circleStrokeWidth")
            }
        }
    }

    // MARK:- Hashable -

    public static func == (lhs: CircleAnnotation, rhs: CircleAnnotation) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }   
}

// End of generated file.