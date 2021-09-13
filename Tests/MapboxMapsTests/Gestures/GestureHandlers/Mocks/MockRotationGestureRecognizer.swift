import UIKit

final class MockRotationGestureRecognizer: UIRotationGestureRecognizer {
    let getStateStub = Stub<Void, UIGestureRecognizer.State>(defaultReturnValue: .possible)
    override var state: UIGestureRecognizer.State {
        get {
            getStateStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }

    let getRotationStub = Stub<Void, CGFloat>(defaultReturnValue: 2)
    override var rotation: CGFloat {
        get {
            getRotationStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }
}
