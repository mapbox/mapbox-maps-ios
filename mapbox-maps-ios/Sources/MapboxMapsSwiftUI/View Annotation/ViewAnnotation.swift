@_spi(Package) import MapboxMaps
import Turf
import SwiftUI

/// Represents view annotation.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct ViewAnnotation<Content: View> {
    var options: ViewAnnotationOptions
    var content: () -> Content

    /// Creates an annotaion with specified options and content builder.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate the view annotation is bound to.
    ///   - size: Size of the annotation. It will be the maximun size the annotation can occupy.
    ///   - allowOverlap: If true, the annotation will be visible even if it collides with other annotations. Defaults to false.
    ///   - anchor: Specifies where the annotation will be located relatively to the given coordinate.
    ///   - offsetX: Additional X offset, positive values move annotation to right.
    ///   - offsetY: Additional Y offset, positive values move annotation to right.
    public init(
        _ coordinate: CLLocationCoordinate2D,
        size: CGSize,
        allowOverlap: Bool = false,
        anchor: ViewAnnotationAnchor = .center,
        offsetX: CGFloat? = nil,
        offsetY: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content) {
        options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: size.width,
            height: size.height,
            allowOverlap: allowOverlap,
            anchor: anchor,
            offsetX: offsetX,
            offsetY: offsetY
        )
        self.content = content
    }
}
