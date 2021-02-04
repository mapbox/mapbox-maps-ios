import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ColorTests: XCTestCase {

    func testColorEncodingAndDecoding() throws {
        let testColor = UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)
        encodeAndDecodeColor(testColor: testColor)
    }

    func testColorEncodingAndDecodingBlack() throws {
        encodeAndDecodeColor(testColor: .black)
    }

    func testColorEncodingAndDecodingWhite() throws {
        encodeAndDecodeColor(testColor: .white)
    }

    func encodeAndDecodeColor(testColor: UIColor, test: String = #function) {
        let color = ColorRepresentable(color: testColor)
        var data: Data?
        do {
            data = try JSONEncoder().encode(color)
        } catch {
            XCTFail("Could not encode color in test: \(test)")
        }

        guard let validData = data else {
            XCTFail("Color data is nil in test: \(test)")
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor == color, "Color should not change after encoding - decoding pass in test: \(test)")
        } catch {
            XCTFail("Could not decode color in test: \(test)")
        }
    }
}
