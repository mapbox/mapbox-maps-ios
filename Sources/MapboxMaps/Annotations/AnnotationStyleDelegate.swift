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

    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws

    func image(withId id: String) -> UIImage?

    func addSource(_ source: Source, id: String) throws

    func setSourceProperty(for sourceId: String, property: String, value: Any) throws

    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
}
