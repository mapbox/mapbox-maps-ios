import UIKit

// MARK: - Image

extension CoreMapsImage {

    /// Initialize an internal `Image` with a `UIImage`.
    ///
    /// - Parameters:
    ///   - uiImage: The source image.
    internal convenience init?(uiImage: UIImage) {
        guard let data = Data(uiImage: uiImage) else {
            Log.warning("Failed to convert UIImage")
            return nil
        }

        self.init(
            width: UInt32(uiImage.size.width * uiImage.scale),
            height: UInt32(uiImage.size.height * uiImage.scale),
            data: DataRef(data: data))
    }
}

private extension Data {
    init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage,
              let data = cgImage.dataProvider?.data else {
            return nil
        }

        let resultSizeInBytes = 4 * cgImage.height * cgImage.width

        if CFDataGetLength(data) == resultSizeInBytes {
            switch cgImage.alphaInfo {
            case .premultipliedLast:
                // Fast path, use existing image data.
                // Handles for most PNG images.
                self.init(referencing: data)
            case .noneSkipLast:
                // RGBX, handles most JPEG images.
                self.init(convertingImageData: data, alphaFirst: false)
            case .noneSkipFirst:
                // XRGB
                self.init(convertingImageData: data, alphaFirst: true)
            default: break
            }
        }

        // Handles all other cases, such as code-generated images, monochrome images.
        self.init(drawing: cgImage)
    }

    init?(convertingImageData: NSData, alphaFirst: Bool) {
        guard let mutableData = convertingImageData.mutableCopy() as? NSMutableData else {
            return nil
        }
        let length = mutableData.length
        guard length > 0,
              length % 4 == 0 else {
            return nil
        }

        let ptr = mutableData.mutableBytes.bindMemory(to: UInt8.self, capacity: length)

        // TODO: measure performance, use Accelerate
        if alphaFirst {
            for i in stride(from: 0, to: length, by: 4) {
                ptr[i]     =  ptr[i + 1]
                ptr[i + 1] =  ptr[i + 2]
                ptr[i + 2] =  ptr[i + 3]
            }
        } else {
            for i in stride(from: 0, to: length, by: 4) {
                ptr[i + 3] = 255
            }

        }
        self.init(referencing: mutableData)
    }

    /// Initialize an internal `Data` type with image data from a `CGImage`
    /// - Parameters:
    ///   - cgImage: The `cgImage` type to pull image data from
    init?(drawing cgImage: CGImage) {
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.width * bytesPerPixel

        let length = bytesPerPixel * cgImage.width * cgImage.height
        guard let data = NSMutableData(length: length) else {
            return nil
        }

        let bitmapInfo = CGImageByteOrderInfo.orderDefault.rawValue |
            CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: data.mutableBytes,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo) else {
            return nil
        }

        context.setBlendMode(.copy)
        context.draw(cgImage,
                     in: CGRect(
                        origin: .zero,
                        size: CGSize(
                            width: CGFloat(cgImage.width),
                            height: CGFloat(cgImage.height))))

        self.init(referencing: data)
    }
}
