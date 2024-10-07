import XCTest
import MapboxMaps

final class DefaultViewportTransitionOptionsTests: XCTestCase {

    func testInitWithDefaultValues() {
        let options = DefaultViewportTransitionOptions()

        XCTAssertEqual(options.maxDuration, 3.5)
    }

    func testInitWithNonDefaultValues() {
        let maxDuration = TimeInterval.testConstantValue()

        let options = DefaultViewportTransitionOptions(
            maxDuration: maxDuration)

        XCTAssertEqual(options.maxDuration, maxDuration)
    }
}
