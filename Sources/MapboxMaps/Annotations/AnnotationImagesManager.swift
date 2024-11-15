import UIKit

internal protocol AnnotationImagesManagerProtocol: AnyObject {
    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets)
    func removeImage(_ imageName: String)
    func register(imagesConsumer: AnnotationImagesConsumer)
    func unregister(imagesConsumer: AnnotationImagesConsumer)
}

internal protocol AnnotationImagesConsumer: AnyObject {
    func isUsingStyleImage(_ imageName: String) -> Bool
}

extension PointAnnotation {
    public struct Image: Hashable, Sendable {
        public var image: UIImage
        public var name: String

        public init(image: UIImage, name: String) {
            self.image = image
            self.name = name
        }
    }
}

extension PointAnnotationManager: AnnotationImagesConsumer {
    func isUsingStyleImage(_ imageName: String) -> Bool {
        allImages.contains(imageName)
    }
}

internal final class AnnotationImagesManager: AnnotationImagesManagerProtocol {

    private let style: StyleProtocol
    private var imagesConsumers = WeakSet<AnnotationImagesConsumer>()
    private var addedAnnotationImages = Set<String>()

    init(style: StyleProtocol) {
        self.style = style
    }

    /// Registers an ``AnnotationImagesConsumer``.
    /// Upon removing an image from ``Style``, this ``AnnotationImagesManager`` will first consult
    /// its consumers and only remove the image if there is no  consumers using this image.
    func register(imagesConsumer: AnnotationImagesConsumer) {
        imagesConsumers.add(imagesConsumer)
    }

    /// Unregisters an ``AnnotationImagesConsumer``.
    func unregister(imagesConsumer: AnnotationImagesConsumer) {
        imagesConsumers.remove(imagesConsumer)
    }

    /// Adds an image to ``Style`` if no image exists under same `id`.
    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) {
        guard !style.imageExists(withId: id) else { return }

        do {
            try style.addImage(image, id: id, sdf: sdf, contentInsets: contentInsets)
            addedAnnotationImages.insert(id)
        } catch {
            Log.warning(
                "Could not add image to style due to error: \(error)",
                category: "Annnotations")
        }
    }

    /// Removes the image from ``Style`` if the image has been added/owned by this ``AnnotationImagesManager``
    /// and if there is no consumers using this image.
    func removeImage(_ imageName: String) {
        guard canRemoveStyleImage(imageName) else { return }

        do {
            try style.removeImage(withId: imageName)
            addedAnnotationImages.remove(imageName)
        } catch {
            Log.warning(
                "Could not remove image from style due to error: \(error)",
                category: "Annnotations")
        }
    }

    private func canRemoveStyleImage(_ imageName: String) -> Bool {
        addedAnnotationImages.contains(imageName)
        && imagesConsumers.allObjects.allSatisfy { !$0.isUsingStyleImage(imageName) }
        && style.imageExists(withId: imageName)
    }
}
