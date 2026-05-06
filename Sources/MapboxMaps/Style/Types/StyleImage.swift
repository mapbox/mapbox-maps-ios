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

        // Stretch and content-box values in pixels must lie within the
        // declared image width/height. `CoreMapsImage.init?(uiImage:)` declares
        // those using `UInt32(size * scale)`, which truncates fractional
        // results. For UIImages whose `size * scale` is non-integer — notably
        // SF Symbols at non-integer point sizes — computing stretches as
        // `Float(size) * scale` left them 0.x pixels past the declared edge,
        // which the native side rejects with "expected stretchX area lies
        // within an image". Floor to the same integer bounds the image is
        // declared at.
        let widthPx = Float(Int(uiImage.size.width * uiImage.scale))
        let heightPx = Float(Int(uiImage.size.height * uiImage.scale))
        self.stretchXFirst = Float(Int(uiImage.capInsets.left * uiImage.scale))
        self.stretchXSecond = widthPx - Float(Int(uiImage.capInsets.right * uiImage.scale))
        self.stretchYFirst = Float(Int(uiImage.capInsets.top * uiImage.scale))
        self.stretchYSecond = heightPx - Float(Int(uiImage.capInsets.bottom * uiImage.scale))

        let contentBoxLeft = Float(Int(contentInsets.left * uiImage.scale))
        let contentBoxRight = widthPx - Float(Int(contentInsets.right * uiImage.scale))
        let contentBoxTop = Float(Int(contentInsets.top * uiImage.scale))
        let contentBoxBottom = heightPx - Float(Int(contentInsets.bottom * uiImage.scale))
        self.contentBox = ImageContent(left: contentBoxLeft,
                                       top: contentBoxTop,
                                       right: contentBoxRight,
                                       bottom: contentBoxBottom)
        self.sdf = sdf
    }
}
