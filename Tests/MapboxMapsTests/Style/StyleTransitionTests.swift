import XCTest

@testable import MapboxMaps

class StyleTransitionTests: XCTestCase {

    func testDecodeHasCorrectConversion() {
        let jsonString = """
        {
            "duration": 1000,
            "delay": 500
        }
        """

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

        let decodedTransition = try! JSONDecoder().decode(StyleTransition.self, from: encodedTransition)

        XCTAssertEqual(transition.duration, decodedTransition.duration, "Duration should be equal to 1.0")
        XCTAssertEqual(transition.delay, decodedTransition.delay, "Delay should be equal to 0.5")
    }
}
