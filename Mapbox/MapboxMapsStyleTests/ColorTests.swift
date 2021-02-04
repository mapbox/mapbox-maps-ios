import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ColorTests: XCTestCase {

    func testColorEncodingAndDecoding() throws {
        let testColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)
        verifyEncodeAndDecodeColor(testColor: testColor)
    }

    func testColorEncodingAndDecodingBlack() throws {
        verifyEncodeAndDecodeColor(testColor: .black)
    }

    func testColorEncodingAndDecodingWhite() throws {
        verifyEncodeAndDecodeColor(testColor: .white)
    }

    func verifyEncodeAndDecodeColor(testColor: UIColor, line: UInt = #line) {
        let color = ColorRepresentable(color: testColor)
        var data: Data?
        do {
            data = try JSONEncoder().encode(color)
        } catch {
            XCTFail("Could not encode color", line: line)
        }

        guard let validData = data else {
            XCTFail("Color data is nil", line: line)
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor == color, "Color should not change after encoding - decoding pass", line: line)
        } catch {
            XCTFail("Could not decode color", line: line)
        }
    }
}
