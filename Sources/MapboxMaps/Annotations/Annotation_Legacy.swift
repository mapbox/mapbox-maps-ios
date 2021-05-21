import Turf
/**
 A protocol that annotations should conform to.
 */

public enum AnnotationType_Legacy {
    case point
    case line
    case polygon
}

public protocol Annotation_Legacy {

    /**
     The unique identifier of the annotation.
     */
    var identifier: String { get }

    /**
     The optional title for an annotation. It will be
     displayed if callouts are enabled.
     */
    var title: String? { get set }

    /**
    The geometry associated with an annotation.
     */
    var type: AnnotationType_Legacy { get }

    /**
     A Boolean value that indicates whether an annotation is selected, either programmatically or via user-interactions.
     */
    var isSelected: Bool { get set }

    /**
     Properties associated with the annotation
     */
    var userInfo: [String: Any]? { get }
}
