import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
final class MockAnnotationStyleDelegate: AnnotationStyleDelegate {
    //swiftlint:disable function_parameter_count
    func image(withId id: String) -> UIImage? {
        return UIImage()
    }

    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws {}
    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {}
    func addSource(_ source: Source, id: String) throws {}
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {}
}
