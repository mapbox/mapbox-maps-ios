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

    func addImagesToStyleIfNeeded(style: StyleProtocol, images: Set<PointAnnotation.Image>) -> Set<String> {
        var addedImages = Set<String>()
        // If the image is not found, add it to the style
        for pointAnnotationImage in images where !style.imageExists(withId: pointAnnotationImage.name) {
            do {
                try style.addImage(pointAnnotationImage.image, id: pointAnnotationImage.name)
                addedImages.insert(pointAnnotationImage.name)
            } catch {
                Log.warning(
                    forMessage: "Could not add image to style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
        return addedImages
    }

    func removeImages(from style: StyleProtocol, images: Set<String>) -> Set<String> {
        var removedImages = Set<String>()
        for image in images where addedImages.contains(image) {
            do {
                try style.removeImage(withId: image)
                removedImages.insert(image)
            } catch {
                Log.warning(
                    forMessage: "Could not remove image from style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
        return removedImages
    }
}
