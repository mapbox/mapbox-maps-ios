import XCTest

@testable import MapboxMaps

class StyleTransitionTests: XCTestCase {
    let jsonString = "{\"delay\":500,\"duration\":1000}"

    func testDecodeHasCorrectConversion() {
        let jsonData = jsonString.data(using: .utf8)!
        let decodedTransition = try! JSONDecoder().decode(StyleTransition.self, from: jsonData)

        XCTAssertEqual(decodedTransition.duration, 1.0, "Duration should be equal to 1.0")
        XCTAssertEqual(decodedTransition.delay, 0.5, "Delay should be equal to 0.5")
    }

    func testEncodeHasCorrectConversion() {
        let transition = StyleTransition(duration: 1.0, delay: 0.5)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encodedTransition = try! encoder.encode(transition)
        let dataString = String(decoding: encodedTransition, as: UTF8.self)

        XCTAssertEqual(dataString, jsonString)
    }
}
