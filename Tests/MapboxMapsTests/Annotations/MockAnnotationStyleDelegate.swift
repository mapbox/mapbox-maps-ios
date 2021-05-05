import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
final class MockAnnotationStyleDelegate: AnnotationStyleDelegate {
    //swiftlint:disable function_parameter_count
    func setStyleImage(image: UIImage,
                       with identifier: String,
                       sdf: Bool,
                       stretchX: [ImageStretches],
                       stretchY: [ImageStretches],
                       imageContent: ImageContent?) -> Result<Bool, ImageError> {
        return .success(true)
    }

    func getStyleImage(with identifier: String) -> Image? {
        return Image(uiImage: UIImage())
    }

    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {}
    func addSource(_ source: Source, id: String) throws {}
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {}
}
