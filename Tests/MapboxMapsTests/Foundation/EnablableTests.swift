import XCTest
@testable import MapboxMaps

final class EnablableTests: XCTestCase {
    func testIsEnabledDefault() {
        let enablable = Enablable()

        XCTAssertTrue(enablable.isEnabled)
    }
}
