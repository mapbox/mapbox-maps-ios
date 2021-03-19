import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

internal class CameraAnimatorTests: XCTestCase {

    var delegate: CameraAnimatorMock!
    var cameraAnimator: CameraAnimator!

    override func setUp() {
        delegate = CameraAnimatorMock()
        cameraAnimator = CameraAnimator(delegate: delegate,
                                        propertyAnimator: UIViewPropertyAnimator(),
                                        owner: AnimationOwner.unspecified)
    }
    
    func testStopAnimationCallsDelegate() {
        cameraAnimator.stopAnimation()
        XCTAssertEqual(delegate.cameraAnimatorStub.invocations.count, 1)
    }

    func testAddCompletionSchedulesACompletion() {
        cameraAnimator.addCompletion({ _ in
            XCTAssertEqual(self.delegate.cameraAnimatorStub.invocations.count, 1)
        })
    }

}
