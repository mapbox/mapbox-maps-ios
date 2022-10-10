import Foundation
import MapboxCoreMaps.CoordinateBounds

/// Responsible to provide a ``CoordinateBounds`` covering the geometry  area that it presents.
public protocol AnnotationFrameable {

    /// Calculates the ``CoordinateBounds`` covering the geometry of the annotation.
    func coordinateBounds(zoom: CGFloat) -> CoordinateBounds
}

// MARK: Conformance

extension Array: AnnotationFrameable where Element: AnnotationFrameable {

    public func coordinateBounds(zoom: CGFloat) -> CoordinateBounds {
        reduce(.empty) { bounds, frame in
            bounds.extend(forArea: frame.coordinateBounds(zoom: zoom))
        }
    }
}

extension ViewAnnotationOptions: AnnotationFrameable {

    public func coordinateBounds(zoom: CGFloat) -> CoordinateBounds {
        guard case .point(let point) = geometry else { fatalError() }

        let frame = frame
        let northeast = point.coordinates.coordinate(at: frame.topRight, zoom: zoom)
        let southwest = point.coordinates.coordinate(at: frame.bottomLeft, zoom: zoom)

        return CoordinateBounds(southwest: southwest, northeast: northeast, infiniteBounds: false)
    }

    private var frame: CGRect {
        guard let width, let height else { return .zero }

        let offset: (x: CGFloat, y: CGFloat) = (width * 0.5, height * 0.5)
        var frame = CGRect(x: -offset.x, y: -offset.y, width: width, height: height)
        let anchor = anchor ?? .center

        switch anchor {
        case .top:
            frame = frame.offsetBy(dx: 0, dy: -offset.y)
        case .topLeft:
            frame = frame.offsetBy(dx: -offset.x, dy: -offset.y)
        case .topRight:
            frame = frame.offsetBy(dx: offset.x, dy: -offset.y)
        case .bottom:
            frame = frame.offsetBy(dx: 0, dy: offset.y)
        case .bottomLeft:
            frame = frame.offsetBy(dx: -offset.x, dy: -offset.y)
        case .bottomRight:
            frame = frame.offsetBy(dx: -offset.x, dy: offset.y)
        case .left:
            frame = frame.offsetBy(dx: -offset.x, dy: 0)
        case .right:
            frame = frame.offsetBy(dx: offset.x, dy: 0)
        default: break
        }

        return frame.offsetBy(dx: offsetX ?? 0, dy: offsetY ?? 0)
    }
}

private extension CoordinateBounds {

    static var empty: CoordinateBounds {
        CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: .infinity, longitude: .infinity),
            northeast: CLLocationCoordinate2D(latitude: .infinity, longitude: .infinity)
        )
    }
}
