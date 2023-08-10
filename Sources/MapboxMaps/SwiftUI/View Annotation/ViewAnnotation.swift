import SwiftUI

/// Represents view annotation.
@_spi(Experimental)
public struct ViewAnnotation: MapContent {
    var viewAnnotationConfig: ViewAnnotationConfig
    var makeViewController: (@escaping (CGSize) -> Void) -> UIViewController

    /// Creates an annotaion with specified options and content builder.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate the view annotation is bound to.
    ///   - allowOverlap: If true, the annotation will be visible even if it collides with other annotations. Defaults to false.
    ///   - anchor: Specifies where the annotation will be located relatively to the given coordinate.
    ///   - offsetX: Additional X offset, positive values move annotation to right.
    ///   - offsetY: Additional Y offset, positive values move annotation to right.
    @available(iOS 13.0, *)
    public init<Content: View>(
        _ coordinate: CLLocationCoordinate2D,
        allowOverlap: Bool = false,
        anchor: ViewAnnotationAnchor = .center,
        offsetX: CGFloat? = nil,
        offsetY: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        viewAnnotationConfig = ViewAnnotationConfig(
            point: Point(coordinate),
            allowOverlap: allowOverlap,
            anchor: anchor,
            offsetX: offsetX,
            offsetY: offsetY
        )
        self.makeViewController = { onSizeChange in
            UIHostingController(rootView: content().onChangeOfSize(perform: onSizeChange))
        }
    }

    func _visit(_ visitor: MapContentVisitor) {
        visitor.add(viewAnnotation: self)
    }
}

/// View annotation configuration
struct ViewAnnotationConfig: Equatable {
    var point: Point
    var allowOverlap: Bool
    var anchor: ViewAnnotationAnchor
    var offsetX: CGFloat?
    var offsetY: CGFloat?
}

extension ViewAnnotation: PrimitiveMapContent {}
