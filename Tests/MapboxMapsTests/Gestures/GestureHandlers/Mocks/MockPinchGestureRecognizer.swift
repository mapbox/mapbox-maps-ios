import UIKit

final class MockPinchGestureRecognizer: UIPinchGestureRecognizer {
    let getStateStub = Stub<Void, UIGestureRecognizer.State>(defaultReturnValue: .possible)
    override var state: UIGestureRecognizer.State {
        get {
            getStateStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }

    let getScaleStub = Stub<Void, CGFloat>(defaultReturnValue: 2)
    override var scale: CGFloat {
        get {
            getScaleStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }

    let getNumberOfTouchesStub = Stub<Void, Int>(defaultReturnValue: 1)
    override var numberOfTouches: Int {
        getNumberOfTouchesStub.call()
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
