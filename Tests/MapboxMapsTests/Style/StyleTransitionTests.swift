import XCTest

@testable import MapboxMaps

class StyleTransitionTests: XCTestCase {
    let jsonString = "{\"delay\":500,\"duration\":1000}"

    func testDecodeHasCorrectConversion() {
        let jsonData = jsonString.data(using: .utf8)!
        let decodedTransition = try! JSONDecoder().decode(StyleTransition.self, from: jsonData)
        let comparingTransition = StyleTransition(duration: 1.0, delay: 0.5)

        XCTAssertEqual(comparingTransition.duration, 1.0, "Duration should be equal to 1.0")
        XCTAssertEqual(decodedTransition.duration, 1.0, "Duration should be equal to 1.0")
        XCTAssertEqual(comparingTransition.delay, 0.5, "Delay should be equal to 0.5")
        XCTAssertEqual(decodedTransition.delay, 0.5, "Delay should be equal to 0.5")
    }

    func testEncodeHasCorrectConversion() {
        let transition = StyleTransition(duration: 1.0, delay: 0.5)
        let encodedTransition = try! JSONEncoder().encode(transition)
        let dataString = String(data: encodedTransition, encoding: .utf8)

        XCTAssertEqual(dataString, jsonString)
    }
}
