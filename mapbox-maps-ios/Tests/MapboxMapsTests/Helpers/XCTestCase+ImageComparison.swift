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

extension XCTestCase {

    /// Simple helper for asynchronous testing.
    /// Usage in XCTestCase method:
    ///   func testSomething() {
    ///       doAsyncThings()
    ///       eventually {
    ///           /* XCTAssert goes here... */
    ///       }
    ///   }
    /// Cloure won't execute until timeout is met. You need to pass in an
    /// timeout long enough for your asynchronous process to finish, if it's
    /// expected to take more than the default 0.01 second.
    ///
    /// - Parameters:
    ///   - timeout: amout of time in seconds to wait before executing the
    ///              closure.
    ///   - closure: a closure to execute when `timeout` seconds has passed
    func eventually(timeout: TimeInterval = 0.01, closure: @escaping () -> Void) {
        let expectation = self.expectation(description: "")
        expectation.fulfillAfter(timeout)
        self.waitForExpectations(timeout: 60) { _ in
            closure()
        }
    }
}

extension XCTestExpectation {

    /// Call `fulfill()` after some time.
    ///
    /// - Parameter time: amout of time after which `fulfill()` will be called.
    func fulfillAfter(_ time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.fulfill()
        }
    }
}
