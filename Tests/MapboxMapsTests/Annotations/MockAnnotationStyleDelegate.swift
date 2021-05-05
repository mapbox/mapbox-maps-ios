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

    func addSource(source: Source, identifier: String) -> Result<Bool, SourceError> {
        return .success(true)
    }

    //swiftlint:disable identifier_name
    func updateSourceProperty(id: String, property: String, value: [String: Any]) -> Result<Bool, SourceError> {
        return .success(true)
    }

    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {
    }
}
