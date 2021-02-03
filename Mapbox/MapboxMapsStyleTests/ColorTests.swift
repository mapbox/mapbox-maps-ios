import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ColorTests: XCTestCase {

    func testColorEncodingAndDecoding() throws {
        let testColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)
        let color = ColorRepresentable(color: testColor)
        var data: Data?
        do {
            data = try JSONEncoder().encode(color)
        } catch {
            XCTFail("Could not encode color")
        }

        guard let validData = data else {
            XCTFail("Color data is nil")
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor == color, "Color should not change after encoding - decoding pass")
        } catch {
            XCTFail("Could not decode color")
        }
    }

    func testNonSRGBColor() throws {
        let testColor = UIColor(patternImage: UIImage())
        let color = ColorRepresentable(color: testColor)
        XCTAssertNil(color)
    }

    func testColorEncodingAndDecodingBlack() throws {
        let color = ColorRepresentable(color: .black)
        var data: Data?
        do {
            data = try JSONEncoder().encode(color)
        } catch {
            XCTFail("Could not encode color")
        }

        guard let validData = data else {
            XCTFail("Color data is nil")
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor == color, "Color should not change after encoding - decoding pass")
        } catch {
            XCTFail("Could not decode color")
        }
    }

    func testColorEncodingAndDecodingWhite() throws {
        let color = ColorRepresentable(color: .white)
        var data: Data?
        do {
            data = try JSONEncoder().encode(color)
        } catch {
            XCTFail("Could not encode color")
        }

        guard let validData = data else {
            XCTFail("Color data is nil")
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor == color, "Color should not change after encoding - decoding pass")
        } catch {
            XCTFail("Could not decode color")
        }
    }
}
