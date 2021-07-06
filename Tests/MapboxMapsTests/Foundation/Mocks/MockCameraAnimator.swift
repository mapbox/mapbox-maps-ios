import Foundation
@testable import MapboxMaps

final class MockCameraAnimator: NSObject, CameraAnimatorInterface {
    func cancel() {
    }

    func update() {
    }

    var state: UIViewAnimatingState = .inactive

    func stopAnimation() {
    }
}
