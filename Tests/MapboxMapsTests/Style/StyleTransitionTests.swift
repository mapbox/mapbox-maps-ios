import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

//swiftlint:disable explicit_top_level_acl explicit_acl
class StyleTransitionTests: XCTestCase {

    func testDecodeHasCorrectConversion() {
        let jsonString = """
        {
            "duration": 1000,
            "delay": 500
        }
        """

        if let jsonData = jsonString.data(using: .utf8) {
            let decodedTransition = try! JSONDecoder().decode(StyleTransition.self, from: jsonData)
            let comparingTransition = StyleTransition(duration: 1.0, delay: 0.5)

            XCTAssertEqual(comparingTransition.duration, decodedTransition.duration, "Duration should be equal to 1.0")
            XCTAssertNotEqual(decodedTransition.duration, 1000, "Duration should be equal to 1.0")
            XCTAssertEqual(comparingTransition.delay, decodedTransition.delay, "Delay should be equal to 0.5")
            XCTAssertNotEqual(decodedTransition.delay, 500, "Duration should be equal to 1.0")
        }
    }

    func testEncodeHasCorrectConversion() {
        let transition = StyleTransition(duration: 1.0, delay: 0.5)
        let encodedTransition = try! JSONEncoder().encode(transition)

        let decodedTransition = try! JSONDecoder().decode(StyleTransition.self, from: encodedTransition)

        XCTAssertEqual(transition.duration, decodedTransition.duration, "Duration should be equal to 1.0")
        XCTAssertEqual(transition.delay, decodedTransition.delay, "Delay should be equal to 0.5")
    }
}
