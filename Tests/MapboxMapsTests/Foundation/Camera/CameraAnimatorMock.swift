import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

final class CameraAnimatorMock: CameraAnimatorDelegate {

    struct CameraAnimatorDelegateParameters {}

    let cameraAnimatorStub = Stub<CameraAnimatorDelegateParameters, Void>()

    public func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                          completion: @escaping AnimationCompletion,
                                          animatingPosition: UIViewAnimatingPosition) {
        cameraAnimatorStub.call(with: CameraAnimatorDelegateParameters())
    }

    public func animatorIsFinished(forAnimator animator: CameraAnimator) {
        cameraAnimatorStub.call(with: CameraAnimatorDelegateParameters())
    }
}
