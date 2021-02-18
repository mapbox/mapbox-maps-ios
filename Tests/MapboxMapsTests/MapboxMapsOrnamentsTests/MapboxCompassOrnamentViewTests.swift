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
            XCTAssert(compass.alpha == 1)
        }
    }

    func testCompassVisibilityHidden() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .hidden)
        // When
        compass.currentBearing = 0
        // Then
        XCTAssert(compass.alpha == 0)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssert(compass.alpha == 0)
        }
    }

    func testCompassVisibilityAdaptive() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .adaptive)
        // When
        compass.currentBearing = 0
        // Then
        XCTAssert(compass.alpha == 0)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssert(compass.alpha == 1)
        }
    }

    func testCompassVisibilityStyleChanging() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .visible)
        compass.currentBearing = 0
        // When
        compass.visibility = .visible
        // Then
        XCTAssert(compass.alpha == 1)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssert(compass.alpha == 0)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssert(compass.alpha == 0)
    }

    func testCompassVisibilityStyleChangingWithBearing() {
        // Given
        let compass = MapboxCompassOrnamentView(visibility: .visible)
        compass.currentBearing = 30
        // When
        compass.visibility = .visible
        // Then
        XCTAssert(compass.alpha == 1)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssert(compass.alpha == 0)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssert(compass.alpha == 1)
    }
}
