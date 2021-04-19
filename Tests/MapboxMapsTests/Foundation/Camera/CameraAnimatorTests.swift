import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

internal class CameraAnimatorTests: XCTestCase {

    // swiftlint:disable weak_delegate
    var delegate: CameraAnimatorDelegateMock!
    var cameraAnimator: CameraAnimator!

    override func setUp() {
        delegate = CameraAnimatorDelegateMock()
        cameraAnimator = CameraAnimator(delegate: delegate,
                                        propertyAnimator: UIViewPropertyAnimator(),
                                        owner: .unspecified)
    }

    func testAddCompletionSchedulesACompletion() {
        cameraAnimator.addCompletion({ _ in
            XCTAssertEqual(self.delegate.schedulePendingCompletionStub.invocations.count, 1)
        })
    }

}
