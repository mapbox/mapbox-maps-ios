import UIKit

final class MockGestureRecognizer: UIGestureRecognizer {
    let requireToFailStub = Stub<UIGestureRecognizer, Void>()
    override func require(toFail otherGestureRecognizer: UIGestureRecognizer) {
        requireToFailStub.call(with: otherGestureRecognizer)
    }
}
