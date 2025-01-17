import UIKit

/// An image to be used in the Style
public struct StyleImage: Equatable, Sendable {

    /// The ID of the image.
    var id: String

    /// The image itself
    var image: UIImage

    /// Option to treat whether image is SDF(signed distance field) or not.
    /// Setting this to `true` allows template images to be recolored. The
    /// default value is `false`.
    var sdf: Bool = false

    /// The distances the edges of content are inset from the image
    var contentInsets: UIEdgeInsets = .zero

    /// Initialize a StyleImage with a new UIImage
    public init(id: String, image: UIImage, sdf: Bool = false, contentInsets: UIEdgeInsets = .zero) {
        self.id = id
        self.image = image
        self.sdf = sdf
        self.contentInsets = contentInsets
    }
}

extension StyleImage: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedImage(image: self))
    }
}

extension StyleImage {
    /// Initialize a StyleImage from an existing UIImage
    public init?(named name: String, sdf: Bool = false, contentInsets: UIEdgeInsets = .zero) {
        guard let image = UIImage(named: name) else { return nil }
        self.init(id: name, image: image, sdf: sdf, contentInsets: contentInsets)
    }
}

extension StyleImage {

    /// Option to treat whether image is SDF(signed distance field) or not.
    /// Setting this to `true` allows template images to be recolored. The
    /// default value is `false`.
    public func sdf(_ newValue: Bool) -> Self {
        with(self, setter(\.sdf, newValue))
    }

    /// The distances the edges of content are inset from the image
    public func contentInsets(_ newValue: UIEdgeInsets) -> Self {
        with(self, setter(\.contentInsets, newValue))
    }
}

struct ImageProperties {
    let id: String
    let scale: Float
    let stretchXFirst: Float
    let stretchXSecond: Float
    let stretchYFirst: Float
    let stretchYSecond: Float
    let contentBox: ImageContent
    let sdf: Bool

    init(styleImage: StyleImage) {
        self.init(uiImage: styleImage.image, contentInsets: styleImage.contentInsets, id: styleImage.id, sdf: styleImage.sdf)
    }

    init(uiImage: UIImage, contentInsets: UIEdgeInsets, id: String, sdf: Bool) {
        self.id = id
        self.scale = Float(uiImage.scale)
        self.stretchXFirst = Float(uiImage.capInsets.left) * scale
        self.stretchXSecond = Float(uiImage.size.width - uiImage.capInsets.right) * scale
        self.stretchYFirst = Float(uiImage.capInsets.top) * scale
        self.stretchYSecond = Float(uiImage.size.height - uiImage.capInsets.bottom) * scale

        let contentBoxLeft = Float(contentInsets.left) * scale
        let contentBoxRight = Float(uiImage.size.width - contentInsets.right) * scale
        let contentBoxTop = Float(contentInsets.top) * scale
        let contentBoxBottom = Float(uiImage.size.height - contentInsets.bottom) * scale
        self.contentBox = ImageContent(left: contentBoxLeft,
                                       top: contentBoxTop,
                                       right: contentBoxRight,
                                       bottom: contentBoxBottom)
        self.sdf = sdf
    }
}
