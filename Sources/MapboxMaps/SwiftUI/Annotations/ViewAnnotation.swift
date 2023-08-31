import SwiftUI

/// Displays view annotation.
///
/// Create a view annotation to display SwiftUI view in ``Map-swift.struct`` content.
///
/// ```swift
/// Map {
///     ViewAnnotation(CLLocationCoordinate2D(...)) {
///        Text("🚀")
///           .background(Circle().fill(.red))
///     }
/// }
/// ```
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct ViewAnnotation: MapContent {
    var viewAnnotationConfig: ViewAnnotationConfig
    var makeViewController: (@escaping (CGSize) -> Void) -> UIViewController

    /// Creates a view annotation.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate the view annotation is bound to.
    ///   - allowOverlap: If true, the annotation will be visible even if it collides with other annotations. Defaults to false.
    ///   - anchor: Specifies where the annotation will be located relatively to the given coordinate.
    ///   - offsetX: Additional X offset, positive values move annotation to right.
    ///   - offsetY: Additional Y offset, positive values move annotation to top.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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
            UIHostingController(rootView: content().fixedSize().onChangeOfSize(perform: onSizeChange))
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
