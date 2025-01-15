/// A geometry to define a portion of screen that should be queried for rendered features.
///
/// See ``MapboxMap/queryRenderedFeatures(featureset:filter:completion:)`` and ``MapboxMap/queryRenderedFeatures(with:options:completion:)`` for more information.
public struct RenderedQueryGeometry {
    let core: CoreRenderedQueryGeometry

    /// Creates the geometry from one point.
    /// - Parameters:
    ///   - point: A point screen coordinate
    public init(point: CGPoint) {
        core = .fromScreenCoordinate(point.screenCoordinate)
    }

    /// Creates the geometry from a bounding box.
    /// - Parameters:
    ///   - boundingBox: A bounding box rectangle.
    public init(boundingBox: CGRect) {
        core = .fromScreenBox(.init(boundingBox))
    }

    /// Creates the geometry from a shape.
    /// - Parameters:
    ///   - shape: Screen coordinates defining the shape.
    public init(shape: [CGPoint]) {
        core = .fromNSArray(shape.map(\.screenCoordinate))
    }
}

/// A convenience protocol for automatic conversion to ``RenderedQueryGeometry``.
public protocol RenderedQueryGeometryConvertible {
    /// The converted geometry.
    var geometry: RenderedQueryGeometry { get }
}

extension CGPoint: RenderedQueryGeometryConvertible {
    public var geometry: RenderedQueryGeometry {
        RenderedQueryGeometry(point: self)
    }
}

extension CGRect: RenderedQueryGeometryConvertible {
    public var geometry: RenderedQueryGeometry {
        RenderedQueryGeometry(boundingBox: self)
    }
}

extension Array: RenderedQueryGeometryConvertible where Element == CGPoint {
    public var geometry: RenderedQueryGeometry {
        RenderedQueryGeometry(shape: self)
    }
}
