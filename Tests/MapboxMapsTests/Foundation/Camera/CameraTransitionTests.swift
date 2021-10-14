import XCTest
import CoreLocation
@testable import MapboxMaps

class CameraTransitionTests: XCTestCase {

    var cameraTransition = CameraTransition(
        cameraState: cameraStateTestValue,
        initialAnchor: .zero)

    func testOptimizeBearingClockwise() {
        let startBearing = 0.0
        let endBearing = 90.0
        cameraTransition.bearing.fromValue = startBearing
        cameraTransition.bearing.toValue = endBearing
        let optimizedBearing = cameraTransition.optimizedBearingToValue

        XCTAssertEqual(optimizedBearing, 90.0)
    }

    func testOptimizeBearingCounterClockwise() {
        let startBearing = 0.0
        let endBearing = 270.0
        cameraTransition.bearing.fromValue = startBearing
        cameraTransition.bearing.toValue = endBearing
        let optimizedBearing = cameraTransition.optimizedBearingToValue

        // We should rotate counter clockwise which is shown by a negative angle
        XCTAssertEqual(optimizedBearing, -90.0)
    }

    func testOptimizeBearingWhenBearingsAreTheSame() {
        let startBearing = -90.0
        let endBearing = 270.0
        cameraTransition.bearing.fromValue = startBearing
        cameraTransition.bearing.toValue = endBearing
        let optimizedBearing = cameraTransition.optimizedBearingToValue

        // -90 and 270 degrees is the same bearing so should just return original
        XCTAssertEqual(optimizedBearing, -90)
    }

    func testOptimizeBearingWhenStartBearingIsNegative() {
        var optimizedBearing: CLLocationDirection?

        // Starting at -90 aka 270 should rotate clockwise to 20
        cameraTransition.bearing.fromValue = -90
        cameraTransition.bearing.toValue = 20

        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, 20)

        // Starting at -90 aka 270 should rotate clockwise to -270 aka 90
        cameraTransition.bearing.fromValue = -90
        cameraTransition.bearing.toValue = -270

        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, 90)
    }

    func testOptimizeBearingWhenStartBearingIsNegativeAndIsLesserThanMinus360() {
        var optimizedBearing: CLLocationDirection?

        cameraTransition.bearing.fromValue = -560
        cameraTransition.bearing.toValue = 0

        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, -360)
    }

    func testOptimizeBearingHandlesNil() {
        var optimizedBearing: CLLocationDirection?

        // Test when no end bearing is provided
        cameraTransition.bearing.fromValue = 0.0
        cameraTransition.bearing.toValue = nil

        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertNil(optimizedBearing)
    }

    func testOptimizeBearingLargerThan360() {
        var optimizedBearing: CLLocationDirection?

        // 719 degrees is the same as 359 degrees. -1 should be returned because it is the shortest path from starting at 90
        cameraTransition.bearing.fromValue = 90
        cameraTransition.bearing.toValue = 719
        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, -1.0)

        // -195 should be returned because it is the shortest path from starting at 180
        cameraTransition.bearing.fromValue = 180
        cameraTransition.bearing.toValue = -555
        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, 165)

        // -160 should be returned because it is the shortest path from starting at 180
        cameraTransition.bearing.fromValue = 180
        cameraTransition.bearing.toValue = -520
        optimizedBearing = cameraTransition.optimizedBearingToValue
        XCTAssertEqual(optimizedBearing, 200)
    }
}
