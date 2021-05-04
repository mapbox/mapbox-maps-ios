public protocol AnnotationInteractionDelegate: AnyObject {
    func didSelectAnnotation(annotation: Annotation)
    func didDeselectAnnotation(annotation: Annotation)
}
