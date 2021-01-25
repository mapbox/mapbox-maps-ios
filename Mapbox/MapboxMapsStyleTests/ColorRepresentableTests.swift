import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ColorRepresentableTests: XCTestCase {

    func testEncodingAndDecoding() throws {
        let colorRepresentable = ColorRepresentable(color: .systemRed)

        var data: Data?
        do {
            data = try JSONEncoder().encode(colorRepresentable)
        } catch {
            XCTFail("Failed to encode ColorRepresentable.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode ColorRepresentable.")
            return
        }

        do {
            let decodedColor = try JSONDecoder().decode(ColorRepresentable.self, from: validData)
            XCTAssert(decodedColor.colorRepresentation == colorRepresentable.colorRepresentation)
            XCTAssert(decodedColor.uiColor == colorRepresentable.uiColor)
        } catch {
            XCTFail("Failed to successfully decode ColorRepresentable")
        }

    }

    func testColorExpression() {
        let color = UIColor.red
        let expressionElements = color.expressionElements
        let expectedExpression = Exp(.rgba) {
            255.0
            0.0
            0.0
            1.0
        }

        XCTAssert(expressionElements == [.argument(.expression(expectedExpression))])
    }
}
