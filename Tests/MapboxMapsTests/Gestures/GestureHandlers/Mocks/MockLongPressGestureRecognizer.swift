import UIKit

final class MockLongPressGestureRecognizer: UILongPressGestureRecognizer {
    let getStateStub = Stub<Void, UIGestureRecognizer.State>(defaultReturnValue: .possible)
    override var state: UIGestureRecognizer.State {
        get {
            getStateStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }

    let locationStub = Stub<UIView?, CGPoint>(defaultReturnValue: .zero)
    override func location(in view: UIView?) -> CGPoint {
        locationStub.call(with: view)
    }

    let getViewStub = Stub<Void, UIView?>(defaultReturnValue: nil)
    override var view: UIView? {
        getViewStub.call()
    }
}
