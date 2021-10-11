import UIKit
@_implementationOnly import MapboxCommon_Private

extension PointAnnotation {
    public struct Image: Hashable {
        public var image: UIImage
        public var name: String

        public init(image: UIImage, name: String) {
            self.image = image
            self.name = name
        }
    }
}

extension PointAnnotationManager {

    func addImageToStyleIfNeeded(style: Style) {
        let pointAnnotationImages = Set(annotations.compactMap(\.image))
        for pointAnnotationImage in pointAnnotationImages {
            // If the image is not found, add it to the style
            if style.image(withId: pointAnnotationImage.name) == nil {
                do {
                    try style.addImage(pointAnnotationImage.image, id: pointAnnotationImage.name, stretchX: [], stretchY: [])
                } catch {
                    Log.warning(
                        forMessage: "Could not add image to style in PointAnnotationManager due to error: \(error)",
                        category: "Annnotations")
                }
            }
        }
    }
}
