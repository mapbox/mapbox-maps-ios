import XCTest
import CocoaImageHashing

extension XCTestCase {
    private var imageComparisonHashDistanceMax: OSHashDistanceType {
        return 3
    }

    func compare(observedImage: UIImage, expectedImageNamed expectedImageName: String, expectedImageScale: CGFloat, attachmentName: String? = nil) -> Bool {

        var equal = false

        defer {
            if !equal {
                let attachment = XCTAttachment(image: observedImage, quality: .original)
                attachment.name = attachmentName ?? "observedImage"
                attachment.lifetime = .keepAlways
                add(attachment)
             }
        }

        guard
            let bundleImage = UIImage(named: expectedImageName, in: .mapboxMapsTests, compatibleWith: nil),
            let bundleCGImage = bundleImage.cgImage else {
            print("warning: Missing expected image from bundle")
            return false
        }

        let expectedImage = UIImage(cgImage: bundleCGImage,
                                    scale: expectedImageScale,
                                    orientation: bundleImage.imageOrientation)

        guard observedImage.scale == expectedImage.scale,
              observedImage.imageOrientation == expectedImage.imageOrientation,
              observedImage.size == expectedImage.size else {
            return false
        }

        // See https://github.com/ameingast/cocoaimagehashing, http://phash.org
        // and https://github.com/aetilius/pHash
        let imageHashing = OSImageHashing.sharedInstance()
        let observedHash = imageHashing.hashImage(observedImage, with: .pHash)
        let expectedHash = imageHashing.hashImage(expectedImage, with: .pHash)
        let imageDistance = imageHashing.hashDistance(observedHash, to: expectedHash, with: .pHash)

        equal = (imageDistance <= imageComparisonHashDistanceMax)

        print("Image comparison distance = \(imageDistance)")

        return equal
    }
}
