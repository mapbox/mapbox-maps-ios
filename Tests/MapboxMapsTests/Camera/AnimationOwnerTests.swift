@testable import MapboxMaps
import XCTest

final class AnimationOwnerTests: XCTestCase {

    func testInitialization() {
        let rawValue = String.randomASCII(withLength: .random(in: 0...10))

        let owner = AnimationOwner(rawValue: rawValue)

        XCTAssertEqual(owner.rawValue, rawValue)
    }

    func testStaticValues() {
        XCTAssertEqual(AnimationOwner.gestures.rawValue, "com.mapbox.maps.gestures")
        XCTAssertEqual(AnimationOwner.unspecified.rawValue, "com.mapbox.maps.unspecified")
        XCTAssertEqual(AnimationOwner.cameraAnimationsManager.rawValue, "com.mapbox.maps.cameraAnimationsManager")
    }
}
