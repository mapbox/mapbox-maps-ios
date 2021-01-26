import Foundation
import UIKit

#if canImport(MapboxMaps)
#else
import MapboxMapsStyle
import MapboxCoreMaps
#endif

//swiftlint:disable class_delegate_protocol
public protocol AnnotationStyleDelegate {
    //swiftlint:disable function_parameter_count
    func setStyleImage(image: UIImage,
                       with identifier: String,
                       sdf: Bool,
                       stretchX: [ImageStretches],
                       stretchY: [ImageStretches],
                       scale: CGFloat,
                       imageContent: ImageContent?) -> Result<Bool, ImageError>

    func getStyleImage(with identifier: String) -> Image?

    func addSource<T: Source>(source: T,
                              identifier: String) -> Result<Bool, SourceError>

    // swiftlint:disable identifier_name
    func updateSourceProperty(id: String,
                              property: String,
                              value: [String: Any]) -> Result<Bool, SourceError>

    func addLayer<T: Layer>(layer: T,
                            layerPosition: LayerPosition?) -> Result<Bool, LayerError>
}
