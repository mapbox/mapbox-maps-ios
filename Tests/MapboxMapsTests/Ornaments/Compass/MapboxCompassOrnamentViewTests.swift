import CoreLocation
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class MapboxCompassOrnamentViewTests: XCTestCase {

    func testCompassVisibilityVisible() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .visible)
        // When
        compass.currentBearing = 0
        // Then
        XCTAssert(compass.alpha == 1)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertFalse(compass.isHidden)
        }
    }

    func testCompassVisibilityHidden() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .hidden)
        // When
        compass.currentBearing = 0
        // Then
        XCTAssertTrue(compass.isHidden)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertTrue(compass.isHidden)
        }
    }

    func testCompassVisibilityAdaptive() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .adaptive)
        // When
        compass.currentBearing = 0
        // Then
        XCTAssertTrue(compass.isHidden)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertFalse(compass.isHidden)
        }
    }

    func testCompassVisibilityStyleChanging() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .visible)
        compass.currentBearing = 0
        // When
        compass.visibility = .visible
        // Then
        XCTAssertFalse(compass.isHidden)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssertTrue(compass.isHidden)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssertTrue(compass.isHidden)
    }

    func testCompassVisibilityStyleChangingWithBearing() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .visible)
        compass.currentBearing = 30
        // When
        compass.visibility = .visible
        // Then
        XCTAssertFalse(compass.isHidden)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssertTrue(compass.isHidden)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssertFalse(compass.isHidden)
    }
}
