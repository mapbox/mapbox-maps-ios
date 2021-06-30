import Foundation
@testable import MapboxMaps

final class MockCameraAnimator: NSObject, CameraAnimatorInterface {
    func cancel() {
    }

    var currentCameraOptions: CameraOptions?

    var state: UIViewAnimatingState = .inactive

    func stopAnimation() {
    }
}
