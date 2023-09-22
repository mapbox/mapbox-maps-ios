import XCTest
import Vision

extension XCTestCase {
    private var imageComparisonHashDistanceMax: Float {
        return 5
    }

    @available(iOS 13.0, *)
    func compare(observedImage: UIImage, expectedImageNamed expectedImageName: String, expectedImageScale: CGFloat, attachmentName: String? = nil, file: StaticString = #filePath, line: UInt = #line) {
        do {
            let attachment = XCTAttachment(image: observedImage, quality: .original)
            attachment.name = attachmentName ?? "observedImage"
            add(attachment)

            guard
                let bundleImage = UIImage(named: expectedImageName, in: .mapboxMapsTests, compatibleWith: nil),
                let bundleCGImage = bundleImage.cgImage else {
                return XCTFail("Missing expected image from bundle", file: file, line: line)
            }

            let expectedImage = UIImage(cgImage: bundleCGImage,
                                        scale: expectedImageScale,
                                        orientation: bundleImage.imageOrientation)

            let expectedImageAttachment = XCTAttachment(image: expectedImage, quality: .original)
            expectedImageAttachment.name = "Expected image"
            add(expectedImageAttachment)

            guard observedImage.scale == expectedImage.scale,
                  observedImage.imageOrientation == expectedImage.imageOrientation,
                  observedImage.size == expectedImage.size else {
                return XCTFail("Observed image traits are not equal to expected one", file: file, line: line)
            }

            let observedHash = try observedImage.visionImageFeaturePrint()
            let expectedHash = try expectedImage.visionImageFeaturePrint()

            var imageDistance: Float = 0
            try expectedHash.computeDistance(&imageDistance, to: observedHash)
            print("Image comparison distance = \(imageDistance)")

            XCTAssertLessThan(imageDistance, imageComparisonHashDistanceMax, file: file, line: line)
        } catch {
            XCTFail("Error during image comparison: \(error)", file: file, line: line)
        }
    }
}

extension UIImage {
    @available(iOS 13.0, *)
    func visionImageFeaturePrint() throws -> VNFeaturePrintObservation {
        let imageRequestHandler = VNImageRequestHandler(cgImage: try XCTUnwrap(cgImage),
                                                                options: [:])
        let imageRequest = VNGenerateImageFeaturePrintRequest()
        // Run requests on the [CI] iOS simulators with no access to the GPU
        imageRequest.preferBackgroundProcessing = false
        imageRequest.usesCPUOnly = true

        try imageRequestHandler.perform([imageRequest])
        return try XCTUnwrap(imageRequest.results?.first as? VNFeaturePrintObservation)
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
