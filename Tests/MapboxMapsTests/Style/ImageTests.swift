import XCTest
@_spi(Internal) import MapboxCoreMaps
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
            scale: 1)

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
            scale: 4)

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
            scale: 3,
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
            scale: 3,
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

    // Regression test: `PointAnnotation.image = .init(image: sfSymbol, ...)`
    // previously triggered "Raster image reference has invalid data size" in
    // the core and rendered nothing. SF Symbols (and the result of
    // `.withTintColor(...)` on them) have a non-nil cgImage whose pixel
    // dimensions don't match `uiImage.size * uiImage.scale`. The default
    // branch in `Data(uiImage:)` used to redraw at cgImage dims, which
    // produced a buffer shorter than what `CoreMapsImage.init` declared to
    // the native side. It now redraws at `size * scale`, so declared
    // dimensions, buffer length, and intended display size agree.
    func testSymbolImageRoundTripsWithMatchingDataSize() throws {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let symbol = try XCTUnwrap(UIImage(systemName: "mappin.circle.fill", withConfiguration: config))
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)

        // Preconditions for the regression: cgImage diverges from size*scale.
        let cgImage = try XCTUnwrap(symbol.cgImage)
        let declaredW = Int(symbol.size.width * symbol.scale)
        let declaredH = Int(symbol.size.height * symbol.scale)
        XCTAssertNotEqual(
            declaredW * declaredH, cgImage.width * cgImage.height,
            "Preconditions: SF Symbol cgImage dims should diverge from size*scale")

        let mbmImage = try XCTUnwrap(CoreMapsImage(uiImage: symbol))

        // The native side rejects any mismatch between declared dims and byte count.
        XCTAssertEqual(Int(mbmImage.width), declaredW)
        XCTAssertEqual(Int(mbmImage.height), declaredH)
        XCTAssertEqual(Int(mbmImage.width * mbmImage.height) * 4, mbmImage.data.data.count)
    }

    // Second half of the SF-Symbol regression: stretch and content-box
    // bounds must lie within the declared image dimensions. For a UIImage
    // whose `size * scale` is not integer (common for SF Symbols at
    // non-integer point sizes), stretchXSecond used to overshoot the
    // truncated UInt32 image width by sub-pixel amounts, producing
    // `StyleError("expected stretchX area lies within an image")`.
    func testImagePropertiesStretchWithinDeclaredBoundsForSymbolImage() throws {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let symbol = try XCTUnwrap(UIImage(systemName: "mappin.circle.fill", withConfiguration: config))
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)

        // Preconditions: size*scale is non-integer — without this, the
        // original float-scaled stretch logic would work.
        let fractionalWidth = symbol.size.width * symbol.scale
        XCTAssertNotEqual(fractionalWidth, fractionalWidth.rounded(.down),
                          "Preconditions: SF Symbol size*scale should be non-integer")

        let props = ImageProperties(uiImage: symbol, contentInsets: .zero, id: "pin", sdf: false)

        let declaredW = Float(UInt32(symbol.size.width * symbol.scale))
        let declaredH = Float(UInt32(symbol.size.height * symbol.scale))
        XCTAssertGreaterThanOrEqual(props.stretchXFirst, 0)
        XCTAssertLessThanOrEqual(props.stretchXSecond, declaredW)
        XCTAssertGreaterThanOrEqual(props.stretchYFirst, 0)
        XCTAssertLessThanOrEqual(props.stretchYSecond, declaredH)
        XCTAssertGreaterThanOrEqual(props.contentBox.left, 0)
        XCTAssertLessThanOrEqual(props.contentBox.right, declaredW)
        XCTAssertGreaterThanOrEqual(props.contentBox.top, 0)
        XCTAssertLessThanOrEqual(props.contentBox.bottom, declaredH)
    }
}
