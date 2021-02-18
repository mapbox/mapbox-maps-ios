public protocol AnnotationInteractionDelegate: class {
    func didSelectAnnotation(annotation: Annotation)
    func didDeselectAnnotation(annotation: Annotation)
}
