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

internal extension PointAnnotationManager {

    func addImagesToStyleIfNeeded(style: StyleProtocol, images: Set<PointAnnotation.Image>) {
        // If the image is not found, add it to the style
        for pointAnnotationImage in images where !style.imageExists(withId: pointAnnotationImage.name) {
            do {
                try style.addImage(pointAnnotationImage.image, id: pointAnnotationImage.name)
            } catch {
                Log.warning(
                    forMessage: "Could not add image to style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
    }

    func removeImages(from style: StyleProtocol, images: Set<String>) {
        for image in images {
            do {
                try style.removeImage(withId: image)
            } catch {
                Log.warning(
                    forMessage: "Could not remove image from style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
    }
}
