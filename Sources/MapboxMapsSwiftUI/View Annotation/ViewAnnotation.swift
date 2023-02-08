import Turf
import SwiftUI

@available(iOS 13.0, *)
public struct ViewAnnotation: Identifiable, Equatable {
    public let id: String

    /// Geometry the view annotation is bound to. Currently only support 'point' geometry type.
    /// Note: geometry must be set when adding a new view annotation, otherwise an operation error will be returned from the call that is associated to this option.
    public var geometry: Geometry

    /// View annotation's size.
    public var size: CGSize

    /// Optional style symbol id connected to given view annotation.
    ///
    /// View annotation's visibility behaviour becomes tied to feature visibility where feature could represent an icon or a text label.
    /// E.g. if the bounded symbol is not visible view annotation also becomes not visible.
    ///
    /// Note: Invalid associatedFeatureId (meaning no actual symbol has such feature id) will lead to the cooresponding annotation to be invisible.
    public var associatedFeatureId: String?

    /// If true, the annotation will be visible even if it collides with other previously drawn annotations. Default to false.
    /// Note: When the value is true, the ordering of the views are determined by the order of their addition.
    public var allowOverlap: Bool

    /// Specifies if this view annotation is selected meaning it should be placed on top of others. Default to false.
    public var selected: Bool

    /// Annotation content builder closure.
    private let annotationContent: () -> any View

    /// The ``ViewAnnotationOptions`` to be used when adding/updating/removing from Map.
    var viewAnnotationOptions: ViewAnnotationOptions {
        ViewAnnotationOptions(
            geometry: geometry,
            width: size.width,
            height: size.height,
            associatedFeatureId: associatedFeatureId,
            allowOverlap: allowOverlap,
            selected: selected
        )
    }

    var body: some View {
        AnyView(annotationContent())
    }

    public init(
        id: String = UUID().uuidString,
        geometry: GeometryConvertible,
        size: CGSize,
        associatedFeatureId: String? = nil,
        allowOverlap: Bool = false,
        selected: Bool = false,
        @ViewBuilder _ annotationContent: @escaping () -> some View
    ) {
        self.id = id
        self.geometry = geometry.geometry
        self.size = size
        self.associatedFeatureId = associatedFeatureId
        self.allowOverlap = allowOverlap
        self.selected = selected
        self.annotationContent = annotationContent
    }

    public static func == (lhs: ViewAnnotation, rhs: ViewAnnotation) -> Bool {
        lhs.id == rhs.id
        && lhs.geometry == rhs.geometry
        && lhs.size == rhs.size
        && lhs.associatedFeatureId == rhs.associatedFeatureId
        && lhs.allowOverlap == rhs.allowOverlap
        && lhs.selected == rhs.selected
    }
}
