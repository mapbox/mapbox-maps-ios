import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
@testable import MapboxMapsStyle
import MapboxCoreMaps
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class AnnotationStyleDelegateMock: AnnotationStyleDelegate {
    //swiftlint:disable function_parameter_count
    func setStyleImage(image: UIImage,
                       with identifier: String,
                       sdf: Bool,
                       stretchX: [ImageStretches],
                       stretchY: [ImageStretches],
                       scale: CGFloat,
                       imageContent: ImageContent?) -> Result<Bool, ImageError> {
        return .success(true)
    }

    func getStyleImage(with identifier: String) -> Image? {
        return Image(uiImage: UIImage())
    }

    func addSource<T>(source: T, identifier: String) -> Result<Bool, SourceError> where T: Source {
        return .success(true)
    }

    //swiftlint:disable identifier_name
    func updateSourceProperty(id: String, property: String, value: [String: Any]) -> Result<Bool, SourceError> {
        return .success(true)
    }

    func addLayer<T>(layer: T, layerPosition: LayerPosition?) -> Result<Bool, LayerError> where T: Layer {
        return .success(true)
    }
}
