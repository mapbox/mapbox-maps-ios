import UIKit

// MARK: - UIImage

extension UIImage {

    /// Initialize a `UIImage` with an internal `Image` type, using a given scale.
    /// - Parameters:
    ///   - mbmImage: The internal `Image` type to use for the `UIImage`.
    ///   - scale: The scale of the new `UIImage`.
    internal convenience init?(mbmImage: CoreMapsImage, scale: CGFloat = ScreenShim.scale) {
        guard let dataProvider = CGDataProvider(data: mbmImage.data.data as CFData) else {
            return nil
        }

        let bitmapInfo = CGImageByteOrderInfo.orderDefault.rawValue |
            // TODO: should be .premultipliedLast, headless metal backend returns non-premultiplied image
            CGImageAlphaInfo.last.rawValue
        let cgImage = CGImage(width: Int(mbmImage.width),
                              height: Int(mbmImage.height),
                              bitsPerComponent: 8,
                              bitsPerPixel: 32,
                              bytesPerRow: Int(mbmImage.width) * 4,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                              provider: dataProvider,
                              decode: nil,
                              shouldInterpolate: false,
                              intent: .defaultIntent)
        guard let image = cgImage else { return nil }
        self.init(cgImage: image, scale: scale, orientation: .up)
    }
}
