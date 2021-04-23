import XCTest
@testable import MapboxMaps

final class FlyToAnimatorTests: XCTestCase {

    let initalCameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 42.3601,
                                                                           longitude: -71.0589),
                                            padding: .zero,
                                            zoom: 10,
                                            bearing: 10,
                                            pitch: 10)

    let finalCameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.7749,
                                                                          longitude: -122.4194),
                                           padding: .zero,
                                           zoom: 10,
                                           bearing: 10,
                                           pitch: 10)

    var flyToAnimator: FlyToCameraAnimator!
    var cameraAnimatorDelegateMock: CameraAnimatorDelegateMock!

    override func setUp() {
        cameraAnimatorDelegateMock = CameraAnimatorDelegateMock()
        flyToAnimator = FlyToCameraAnimator(delegate: cameraAnimatorDelegateMock)
        flyToAnimator.makeFlyToInterpolator(from: initalCameraOptions,
                                            to: finalCameraOptions,
                                            duration: 10,
                                            screenFullSize: .init(width: 500, height: 500))
    }

    func testMakeFlyToInterpolator() {
        XCTAssertNotNil(flyToAnimator.flyToInterpolator)
        XCTAssertNotNil(flyToAnimator.delegate)
        XCTAssertEqual(flyToAnimator.finalCameraOptions, finalCameraOptions)
        XCTAssertEqual(flyToAnimator.animationDuration, 10)

    }

    func testStartAnimation() {
        flyToAnimator.startAnimation()
        XCTAssertEqual(flyToAnimator.state, .active)
        XCTAssertNotNil(flyToAnimator.startTime)
        XCTAssertNotNil(flyToAnimator.endTime)
    }

    func testAddCompletion() {
        flyToAnimator.addCompletion { (position) in
            print(position)
        }

        XCTAssertNotNil(flyToAnimator.animationCompletion)
    }

    func testStopAnimation() {

        flyToAnimator.addCompletion { (position) in
            print(position)
        }

        flyToAnimator.startAnimation()

        flyToAnimator.stopAnimation()

        XCTAssertEqual(flyToAnimator.state, .stopped)
        XCTAssertNil(flyToAnimator.flyToInterpolator)
        XCTAssertEqual(cameraAnimatorDelegateMock.schedulePendingCompletionStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimatorDelegateMock.schedulePendingCompletionStub.invocations.first!.parameters.animatingPosition, .current)
    }

    func testUpdate() {
        flyToAnimator.startAnimation()
        flyToAnimator.update()
        XCTAssertEqual(cameraAnimatorDelegateMock.jumpToStub.invocations.count, 1)
    }

}
