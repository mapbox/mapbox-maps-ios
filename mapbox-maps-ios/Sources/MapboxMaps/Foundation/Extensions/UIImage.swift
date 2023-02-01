import UIKit

// MARK: - UIImage

extension UIImage {

    /// Initialize a `UIImage` with an internal `Image` type, using a givens scale.
    /// - Parameters:
    ///   - mbxImage: The internal `Image` type to use for the `UIImage`.
    ///   - scale: The scale of the new `UIImage`.
    internal convenience init?(mbxImage: Image, scale: CGFloat = UIScreen.main.scale) {
        let cgImage = mbxImage.cgImage().takeRetainedValue()

        let size = CGSize(width: CGFloat(CGFloat(mbxImage.width) / scale),
                          height: CGFloat(CGFloat(mbxImage.height) / scale))

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        let rect = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(bounds: rect, format: format)

        let generated = renderer.image { ( rendererContext )  in
            let context = rendererContext.cgContext
            context.draw(cgImage, in: rect)
        }

        guard let generatedImage = generated.cgImage else { return nil }

        self.init(cgImage: generatedImage, scale: scale, orientation: .downMirrored)
    }
}
