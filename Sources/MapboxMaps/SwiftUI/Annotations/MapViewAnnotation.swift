import SwiftUI

/// Displays view annotation.
///
/// Create a view annotation to display SwiftUI vieapp in preview modew in ``Map-swift.struct`` content.
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
public struct MapViewAnnotation: MapContent {
    var config: ViewAnnotationConfig
    var makeViewController: (@escaping (CGSize) -> Void) -> UIViewController

    /// Creates a view annotation.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate the view annotation is bound to.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init<Content: View>(
        _ coordinate: CLLocationCoordinate2D,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(.geometry(Point(coordinate)), content: content)
    }

    /// Creates a view annotation.
    ///
    /// - Parameters:
    ///   - annotatedFeature: Associates the view annotation with the feature geometry. The geometry may be any `Geometry`, or a feature rendered on a specified layer.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init<Content: View>(
        _ annotatedFeature: AnnotatedFeature,
        @ViewBuilder content: @escaping () -> Content
    ) {
        config = ViewAnnotationConfig(annotatedFeature: annotatedFeature)
        makeViewController = { onSizeChange in
            UIHostingController(rootView: content().fixedSize().onChangeOfSize(perform: onSizeChange))
        }
    }

    func _visit(_ visitor: MapContentVisitor) {
        visitor.add(viewAnnotation: self)
    }

    /// If true, the annotation will be visible even if it collides with other annotations. Defaults to `false`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func allowOverlap(_ allowOverlap: Bool) -> MapViewAnnotation {
        with(self, setter(\.config.allowOverlap, allowOverlap))
    }

    /// Specifies if this view annotation is visible or not. Defaults to `true`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func visible(_ visible: Bool) -> MapViewAnnotation {
        with(self, setter(\.config.visible, visible))
    }

    /// Specifies if this view annotation is selected meaning it should be placed on top of others. Defaults to `false`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func selected(_ selected: Bool = false) -> MapViewAnnotation {
        with(self, setter(\.config.selected, selected))
    }

    /// Available anchor choices for annotation placement.
    ///
    /// The first anchor in the list that allows the view annotation to be placed in the view is picked.
    /// By default, the annotation will be placed in center.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func variableAnchors(_ variableAnchors: [ViewAnnotationAnchorConfig]) -> MapViewAnnotation {
        with(self, setter(\.config.variableAnchors, variableAnchors))
    }
}

struct ViewAnnotationConfig: Equatable {
    var annotatedFeature: AnnotatedFeature
    var allowOverlap: Bool = false
    var visible: Bool = true
    var selected: Bool = false
    var variableAnchors: [ViewAnnotationAnchorConfig] = .center
}

extension MapViewAnnotation: PrimitiveMapContent {}
