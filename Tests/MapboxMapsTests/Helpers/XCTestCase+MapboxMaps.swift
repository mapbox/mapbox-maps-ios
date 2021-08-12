import XCTest
import MapboxMaps
import CocoaImageHashing

extension XCTestCase {
    func guardForMetalDevice() throws {
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }
    }

    func mapboxAccessToken() throws -> String {
        func token() throws -> String {
            // User defaults can override plist
            if let token = UserDefaults.standard.string(forKey: "MBXAccessToken") {
                print("Found access token from UserDefaults (command line parameter?)")
                return token
            } else if let token = Bundle.mapboxMapsTests.infoDictionary?["MBXAccessToken"] as? String {
                print("Found access token in Info.plist")
                return token
            } else if let url = Bundle.mapboxMapsTests.url(forResource: "MapboxAccessToken", withExtension: nil),
                      let token = try? String(contentsOf: url) {
                print("Found access token in MapboxAccessToken")
                return token
            } else {
                throw XCTSkip("Mapbox access token not found")
            }
        }

        func validated(token: String) throws -> String {
            if token.starts(with: "pk.") {
                // ok
            } else if token.isEmpty {
                print("⚠️ token is empty.")
            } else {
                throw XCTSkip("Mapbox access token is invalid")
            }
            return token
        }

        return try validated(token: token()).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var imageComparisonHashDistanceMax: OSHashDistanceType {
        return 2
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
