import UIKit

final class MockTapGestureRecognizer: UITapGestureRecognizer {
    let getStateStub = Stub<Void, UIGestureRecognizer.State>(defaultReturnValue: .possible)
    override var state: UIGestureRecognizer.State {
        get {
            getStateStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }
}
