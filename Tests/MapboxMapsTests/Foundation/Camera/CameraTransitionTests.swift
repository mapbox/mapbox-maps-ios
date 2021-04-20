import XCTest
@testable import MapboxMaps

class CameraTransitionTests: XCTestCase {

    func testOptimizeBearingClockwise() {
        let startBearing = 0.0
        let endBearing = 90.0
        let optimizedBearing = CameraTransition.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        XCTAssertEqual(optimizedBearing, 90.0)
    }

    func testOptimizeBearingCounterClockwise() {
        let startBearing = 0.0
        let endBearing = 270.0
        let optimizedBearing = CameraTransition.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        // We should rotate counter clockwise which is shown by a negative angle
        XCTAssertEqual(optimizedBearing, -90.0)
    }

    func testOptimizeBearingWhenBearingsAreTheSame() {
        let startBearing = -90.0
        let endBearing = 270.0
        let optimizedBearing = CameraTransition.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        // -90 and 270 degrees is the same bearing so should just return original
        XCTAssertEqual(optimizedBearing, -90)
    }

    func testOptimizeBearingWhenStartBearingIsNegative() {
        var optimizedBearing: CLLocationDirection?

        // Starting at -90 aka 270 should rotate clockwise to 20
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: -90.0, endBearing: 20.0)
        XCTAssertEqual(optimizedBearing, 20)

        // Starting at -90 aka 270 should rotate clockwise to -270 aka 90
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: -90.0, endBearing: -270)
        XCTAssertEqual(optimizedBearing, 90)
    }

    func testOptimizeBearingHandlesNil() {
        var optimizedBearing: CLLocationDirection?

        // Test when no end bearing is provided
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: 0.0, endBearing: nil)
        XCTAssertNil(optimizedBearing)

        // Test when no start bearing is provided
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: nil, endBearing: 90)
        XCTAssertNil(optimizedBearing)

        // Test when no bearings are provided
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: nil, endBearing: nil)
        XCTAssertNil(optimizedBearing)
    }

    func testOptimizeBearingLargerThan360() {
        var optimizedBearing: CLLocationDirection?

        // 719 degrees is the same as 359 degrees. -1 should be returned because it is the shortest path from starting at 90
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: 90.0, endBearing: 719)
        XCTAssertEqual(optimizedBearing, -1.0)

        // -195 should be returned because it is the shortest path from starting at 180
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: 180, endBearing: -555)
        XCTAssertEqual(optimizedBearing, 165)

        // -160 should be returned because it is the shortest path from starting at 180
        optimizedBearing = CameraTransition.optimizeBearing(startBearing: 180, endBearing: -520)
        XCTAssertEqual(optimizedBearing, 200)
    }
}
