import XCTest
@_spi(Experimental) @testable import MapboxMaps

class CameraTransitionTests: XCTestCase {

    var cameraTransition = CameraTransition(
        cameraState: cameraStateTestValue,
        initialAnchor: .zero)

    func testPositionPointFromValueComesFromCameraState() {
        let transition = CameraTransition(
            cameraState: CameraState(
                center: .init(latitude: 0, longitude: 0),
                padding: .zero,
                zoom: 0,
                bearing: 0,
                pitch: 0,
                verticalFov: 10,
                positionPoint: CameraPositionPoint(x: -0.5, y: 0.25)),
            initialAnchor: .zero)

        XCTAssertEqual(transition.positionPoint.fromValue, CGPoint(x: -0.5, y: 0.25))
        XCTAssertNil(transition.positionPoint.toValue)
        XCTAssertEqual(transition.fromCameraOptions.positionPoint, CameraPositionPoint(x: -0.5, y: 0.25))
        XCTAssertNil(transition.toCameraOptions.positionPoint)
    }

    func testPositionPointToCameraOptions() {
        cameraTransition.positionPoint.toValue = CGPoint(x: 0.75, y: -1)

        XCTAssertEqual(cameraTransition.toCameraOptions.positionPoint, CameraPositionPoint(x: 0.75, y: -1))
    }

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

    func testViewPointFromValueComesFromCameraState() {
        var state = cameraStateTestValue
        state.viewPoint = .viewPoint(CameraViewPoint(x: 0.5, y: -0.5))
        let transition = CameraTransition(cameraState: state, initialAnchor: .zero)

        XCTAssertEqual(transition.viewPoint.fromValue, .viewPoint(CameraViewPoint(x: 0.5, y: -0.5)))
        XCTAssertNil(transition.viewPoint.toValue)
        XCTAssertEqual(transition.fromCameraOptions.viewPoint, .viewPoint(CameraViewPoint(x: 0.5, y: -0.5)))
        XCTAssertNil(transition.toCameraOptions.viewPoint)
    }

    func testViewPointToCameraOptions() {
        cameraTransition.viewPoint.toValue = .followsPositionPoint

        XCTAssertEqual(cameraTransition.toCameraOptions.viewPoint, .followsPositionPoint)
    }

    func testFollowingViewPointWithoutPaddingIsThePositionPoint() {
        let point = CameraViewPoint(
            followingPositionPoint: CameraPositionPoint(x: 0.5, y: -0.25), padding: .zero, size: CGSize(width: 200, height: 400))

        XCTAssertEqual(point.x, 0.5, accuracy: 1e-9)
        XCTAssertEqual(point.y, -0.25, accuracy: 1e-9)
    }

    func testFollowingViewPointAccountsForPadding() {
        // The padded box spans x 100...200 and y 0...100, so its centre is at (150, 50).
        let point = CameraViewPoint(
            followingPositionPoint: CameraPositionPoint(x: 0, y: 0),
            padding: UIEdgeInsets(top: 0, left: 100, bottom: 100, right: 0),
            size: CGSize(width: 200, height: 200))

        XCTAssertEqual(point.x, 0.5, accuracy: 1e-9)
        XCTAssertEqual(point.y, -0.5, accuracy: 1e-9)
    }

    func testFollowingViewPointIsClampedToUnitSquare() {
        // Padding that exceeds the map moves the padded box centre far outside it on both axes.
        let point = CameraViewPoint(
            followingPositionPoint: CameraPositionPoint(x: 0, y: 0),
            padding: UIEdgeInsets(top: -200, left: 300, bottom: 200, right: -100),
            size: CGSize(width: 100, height: 100))

        XCTAssertEqual(point, CameraViewPoint(x: 1, y: -1))
    }

    func testFollowingViewPointForEmptySizeIsCentered() {
        let point = CameraViewPoint(
            followingPositionPoint: CameraPositionPoint(x: 1, y: 1), padding: .zero, size: .zero)

        XCTAssertEqual(point, CameraViewPoint(x: 0, y: 0))
    }

    private func makePath(
        from: CameraViewPointState,
        to: CameraViewPointState?,
        toPadding: UIEdgeInsets = .zero
    ) -> ViewPointPath? {
        ViewPointPath(
            from: from,
            to: to,
            fromCamera: .init(positionPoint: CameraPositionPoint(x: 0, y: 0), padding: .zero),
            toCamera: .init(positionPoint: CameraPositionPoint(x: 0, y: 0), padding: toPadding),
            size: CGSize(width: 200, height: 200))
    }

    func testViewPointPathIsNilWithoutTargetOrWhenBothFollow() {
        XCTAssertNil(makePath(from: .followsPositionPoint, to: nil))
        XCTAssertNil(makePath(from: .viewPoint(CameraViewPoint(x: 1, y: 1)), to: nil))
        XCTAssertNil(makePath(from: .followsPositionPoint, to: .followsPositionPoint))
    }

    func testViewPointPathBetweenPinnedPoints() throws {
        let to = CameraViewPointState.viewPoint(CameraViewPoint(x: 1, y: -1))
        let path = try XCTUnwrap(makePath(from: .viewPoint(CameraViewPoint(x: -1, y: 1)), to: to))

        XCTAssertEqual(path.finalState, to)
        XCTAssertFalse(path.releasesViewPoint)
        XCTAssertEqual(path.point(at: 0.25), CameraViewPoint(x: -0.5, y: 0.5))
    }

    func testViewPointPathFromFollowingStartsAtFollowingPoint() throws {
        let path = try XCTUnwrap(makePath(from: .followsPositionPoint, to: .viewPoint(CameraViewPoint(x: 1, y: 1))))

        XCTAssertEqual(path.from, CameraViewPoint(x: 0, y: 0))
    }

    func testViewPointPathReleaseEndsAtTargetFollowingPoint() throws {
        let path = try XCTUnwrap(makePath(
            from: .viewPoint(CameraViewPoint(x: 1, y: 1)),
            to: .followsPositionPoint,
            toPadding: UIEdgeInsets(top: 0, left: 100, bottom: 100, right: 0)))

        XCTAssertEqual(path.to.x, 0.5, accuracy: 1e-9)
        XCTAssertEqual(path.to.y, -0.5, accuracy: 1e-9)
        XCTAssertEqual(path.finalState, .followsPositionPoint)
        XCTAssertTrue(path.releasesViewPoint)
    }

    func testViewPointPathClampsOutOfRangePointsAndOvershoot() throws {
        let path = try XCTUnwrap(makePath(
            from: .viewPoint(CameraViewPoint(x: 0, y: 0)), to: .viewPoint(CameraViewPoint(x: 3, y: -3))))

        XCTAssertEqual(path.finalState, .viewPoint(CameraViewPoint(x: 1, y: -1)))
        XCTAssertEqual(path.point(at: 1.2), CameraViewPoint(x: 1, y: -1))
    }
}
