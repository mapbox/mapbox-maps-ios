import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

public class CameraAnimatorMock: CameraAnimatorDelegate {
    func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                   completion: @escaping AnimationCompletion,
                                   animatingPosition: UIViewAnimatingPosition) {
        print("Mock stub")
    }

    func animatorIsFinished(forAnimator animator: CameraAnimator) {
        print("Mock stub")
    }


}
