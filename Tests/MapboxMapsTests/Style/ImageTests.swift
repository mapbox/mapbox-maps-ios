import XCTest
import MapboxCoreMaps
@testable import MapboxMaps

final class ImageTests: XCTestCase {

    func makeImageWithUIGraphicsContext(width: Int,
                                        height: Int,
                                        scale: Int) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, CGFloat(scale))
        UIColor.red.withAlphaComponent(0.5).setFill()
        UIRectFill(rect)
        let generated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return generated!
    }

    func makeImageWithCGContext(width: Int,
                                height: Int,
                                scale: Int,
                                alphaInfo: CGImageAlphaInfo = .premultipliedLast) -> UIImage {
        let scaledWidth = width * scale
        let scaledHeight = height * scale
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * scaledWidth
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: scaledWidth,
            height: scaledHeight,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue)!
        context.setFillColorSpace(colorSpace)
        context.setFillColor([0.0, 1.0, 0.0, 0.5])
        context.fill(CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        return UIImage(
            cgImage: context.makeImage()!,
            scale: CGFloat(scale),
            orientation: .up)
    }

    func testConvertGeneratedARGBUIImage() throws {
        let image = makeImageWithUIGraphicsContext(
            width: 1,
            height: 1,
            scale: .random(in: 1...4))

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: image))

        XCTAssertEqual(CGFloat(mbmImage.width), image.scale)
        XCTAssertEqual(mbmImage.data.data[0], 128)
        XCTAssertEqual(mbmImage.data.data[1], 0)
        XCTAssertEqual(mbmImage.data.data[2], 0)
        XCTAssertEqual(mbmImage.data.data[3], 128)
    }

    func testConvertGeneratedRGBAUIImage() throws {
        let image = makeImageWithCGContext(
            width: 1,
            height: 1,
            scale: .random(in: 1...4))

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: image))

        XCTAssertEqual(CGFloat(mbmImage.width), image.scale)
        XCTAssertEqual(mbmImage.data.data[0], 0)
        XCTAssertEqual(mbmImage.data.data[1], 128)
        XCTAssertEqual(mbmImage.data.data[2], 0)
        XCTAssertEqual(mbmImage.data.data[3], 128)
    }

    func testConvertGeneratedRGBXUIImage() throws {
        let image = makeImageWithCGContext(
            width: 1,
            height: 1,
            scale: .random(in: 1...4),
            alphaInfo: .noneSkipLast)

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: image))

        XCTAssertEqual(CGFloat(mbmImage.width), image.scale)
        XCTAssertEqual(mbmImage.data.data[0], 0)
        XCTAssertEqual(mbmImage.data.data[1], 128)
        XCTAssertEqual(mbmImage.data.data[2], 0)
        XCTAssertEqual(mbmImage.data.data[3], 255)
    }

    func testConvertGeneratedXRGBUIImage() throws {
        let image = makeImageWithCGContext(
            width: 1,
            height: 1,
            scale: .random(in: 1...4),
            alphaInfo: .noneSkipFirst)

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: image))

        XCTAssertEqual(CGFloat(mbmImage.width), image.scale)
        XCTAssertEqual(mbmImage.data.data[0], 0)
        XCTAssertEqual(mbmImage.data.data[1], 128)
        XCTAssertEqual(mbmImage.data.data[2], 0)
        XCTAssertEqual(mbmImage.data.data[3], 255)
    }

    func testConvertImageWithPaddedRows() throws {
        let width = 3
        let height = 1
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * (width + 1) // pad rows
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.setFillColorSpace(colorSpace)
        context.setFillColor([0.0, 1.0, 0.0, 0.5])
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = UIImage(
            cgImage: context.makeImage()!,
            scale: 1,
            orientation: .up)

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: image))

        XCTAssertEqual(Int(mbmImage.width), width)
        XCTAssertEqual(mbmImage.data.data[0], 0)
        XCTAssertEqual(mbmImage.data.data[1], 128)
        XCTAssertEqual(mbmImage.data.data[2], 0)
        XCTAssertEqual(mbmImage.data.data[3], 128)

        // The resulting image should not have padded rows.
        XCTAssertEqual(Int(mbmImage.width * mbmImage.height) * bytesPerPixel, mbmImage.data.data.count)
    }
}
