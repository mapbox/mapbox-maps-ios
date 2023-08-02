import UIKit
@testable import MapboxMaps

final class MockAnnotationImagesManager: AnnotationImagesManagerProtocol {

    func register(imagesConsumer: AnnotationImagesConsumer) {}
    func unregister(imagesConsumer: AnnotationImagesConsumer) {}

    struct AddImageParameters {
        let image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets
    }
    let addImageStub = Stub<AddImageParameters, Void>()
    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) {
        addImageStub.call(with: .init(image: image, id: id, sdf: sdf, contentInsets: contentInsets))
    }

    let removeImageStub = Stub<String, Void>()
    func removeImage(_ imageName: String) {
        removeImageStub.call(with: imageName)
    }
}
