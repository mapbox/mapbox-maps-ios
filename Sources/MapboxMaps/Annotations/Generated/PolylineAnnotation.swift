
// This file is generated.
import Foundation
import Turf

public struct PolylineAnnotation: Hashable {

    // Identifier for this annotation
    public let id: String

    // The feature backing this annotation
    internal var feature: Turf.Feature

    public init(id: String = UUID().uuidString, line: Turf.LineString) {
        self.id = id
        self.feature = Turf.Feature(line)
        self.feature.properties = ["id": id]
    }

    public init(id: String = UUID().uuidString, lines: Turf.MultiLineString) {
        self.id = id
        self.feature = Turf.Feature(lines)
        self.feature.properties = ["id": id]
    }

    // MARK:- Properties -

    /// The display of lines when joining.
    public var lineJoin: LineJoin? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineJoin)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-join"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineJoin")
            }
        }
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineSortKey)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-sort-key"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineSortKey")
            }
        }
    }

    /// Blur applied to the line, in pixels.
    public var lineBlur: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineBlur)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-blur"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineBlur")
            }
        }
    }

    /// The color with which the line will be drawn.
    public var lineColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineColor")
            }
        }
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineGapWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-gap-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineGapWidth")
            }
        }
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineOffset)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-offset"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineOffset")
            }
        }
    }

    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineOpacity")
            }
        }
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        didSet {
            do {
                let data = try JSONEncoder().encode(linePattern)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-pattern"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.linePattern")
            }
        }
    }

    /// Stroke thickness.
    public var lineWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(lineWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["line-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PolylineAnnotation.lineWidth")
            }
        }
    }

    // MARK:- Hashable -

    public static func == (lhs: PolylineAnnotation, rhs: PolylineAnnotation) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }   
}

// End of generated file.