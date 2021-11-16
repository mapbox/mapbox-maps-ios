@testable import MapboxMaps

final class MockAnnotationInteractionDelegate: AnnotationInteractionDelegate {
    let didDetectTappedAnnotations = Stub<Void, Void>()
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        didDetectTappedAnnotations.call()
    }
}
