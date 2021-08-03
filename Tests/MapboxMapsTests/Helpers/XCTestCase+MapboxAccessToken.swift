import XCTest
import MapboxMaps

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

    func compare(observedImage: UIImage, expectedImageNamed expectedImageName: String, expectedImageScale: CGFloat, attachmentName: String? = nil) -> Bool {
        guard let bundleImage = UIImage(named: expectedImageName, in: Bundle.module, compatibleWith: nil) else {
            fatalError("Missing expected image from bundle")
        }

        let expectedImage = UIImage(cgImage: bundleImage.cgImage!,
                                    scale: expectedImageScale,
                                    orientation: bundleImage.imageOrientation)

        guard observedImage.scale == expectedImage.scale,
              observedImage.imageOrientation == expectedImage.imageOrientation,
              observedImage.size == expectedImage.size else {
            return false
        }

        // Just comparing pngData is not sufficient. Embedding images in xcassets
        // can modify the RGB colors (presumably from compression/palette generation)
        let result = try! compare(observedImage: observedImage, expectedImage: expectedImage, rgbDistance: 5)

        if !result {
            let attachment = XCTAttachment(image: observedImage)
            attachment.name = attachmentName ?? "observedImage"
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        return result
    }

    // Modified from https://stackoverflow.com/a/53958281
    // See: https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
    private func compare(observedImage: UIImage, expectedImage: UIImage, rgbDistance: Float) throws -> Bool {
        guard let expectedCGImage = expectedImage.cgImage, let observedCGImage = observedImage.cgImage else {
            throw "unableToGetCGImageFromData"
        }
        guard let expectedColorSpace = expectedCGImage.colorSpace, let observedColorSpace = observedCGImage.colorSpace else {
            throw "unableToGetColorSpaceFromCGImage"
        }

        if (expectedCGImage.width != observedCGImage.width) || (expectedCGImage.height != observedCGImage.height) {
            throw "imagesHasDifferentSizes"
        }

        let imageSize = CGSize(width: expectedCGImage.width, height: expectedCGImage.height)
        let numberOfPixels = Int(imageSize.width * imageSize.height)

        // Checking that our `UInt32` buffer has same number of bytes as image has.
        let bytesPerRow = min(expectedCGImage.bytesPerRow, observedCGImage.bytesPerRow)
        assert(MemoryLayout<UInt32>.stride == bytesPerRow / Int(imageSize.width))

        let expectedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
        let observedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)

        defer {
            expectedPixels.deallocate()
            observedPixels.deallocate()
        }

        let expectedPixelsRaw = UnsafeMutableRawPointer(expectedPixels)
        let observedPixelsRaw = UnsafeMutableRawPointer(observedPixels)

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let expectedContext = CGContext(data: expectedPixelsRaw,
                                              width: Int(imageSize.width),
                                              height: Int(imageSize.height),
                                              bitsPerComponent: expectedCGImage.bitsPerComponent,
                                              bytesPerRow: bytesPerRow,
                                              space: expectedColorSpace,
                                              bitmapInfo: bitmapInfo.rawValue) else {
            throw "unableToInitializeContext"
        }

        guard let observedContext = CGContext(data: observedPixelsRaw,
                                              width: Int(imageSize.width),
                                              height: Int(imageSize.height),
                                              bitsPerComponent: observedCGImage.bitsPerComponent,
                                              bytesPerRow: bytesPerRow,
                                              space: observedColorSpace,
                                              bitmapInfo: bitmapInfo.rawValue) else {
            throw "unableToInitializeContext"
        }

        expectedContext.draw(expectedCGImage, in: CGRect(origin: .zero, size: imageSize))
        observedContext.draw(observedCGImage, in: CGRect(origin: .zero, size: imageSize))

        let expectedBuffer = UnsafeBufferPointer(start: expectedPixels, count: numberOfPixels)
        let observedBuffer = UnsafeBufferPointer(start: observedPixels, count: numberOfPixels)

        var isEqual = true

        if rgbDistance == 0 {
            isEqual = expectedBuffer.elementsEqual(observedBuffer)
        } else {
            // Go through each pixel in turn and see if it is different
            var maxDistance: Float = 0
            for pixel in 0 ..< numberOfPixels {

                let expectedRGBA: UInt32 = expectedBuffer[pixel]
                let observedRGBA: UInt32 = observedBuffer[pixel]

                if expectedRGBA != observedRGBA {
                    let expected = simd_float4(Float((expectedRGBA >>  0) & 0xff),
                                               Float((expectedRGBA >>  8) & 0xff),
                                               Float((expectedRGBA >> 16) & 0xff),
                                               Float((expectedRGBA >> 24) & 0xff))

                    let observed = simd_float4(Float((observedRGBA >>  0) & 0xff),
                                               Float((observedRGBA >>  8) & 0xff),
                                               Float((observedRGBA >> 16) & 0xff),
                                               Float((observedRGBA >> 24) & 0xff))

                    let distance = simd_distance(expected, observed)
                    maxDistance = max(distance, maxDistance)

                    // If this pixel is different, increment the pixel diff count and see if we have hit our limit.
                    if maxDistance > rgbDistance {
                        isEqual = false
                        break
                    }
                }
            }
        }

        return isEqual
    }
}
