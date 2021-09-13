import UIKit

final class MockPanGestureRecognizer: UIPanGestureRecognizer {
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

    struct LocationOfTouchParams {
        var touchIndex: Int
        var view: UIView?
    }
    let locationOfTouchStub = Stub<LocationOfTouchParams, CGPoint>(defaultReturnValue: .zero)
    override func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint {
        locationOfTouchStub.call(with: LocationOfTouchParams(touchIndex: touchIndex, view: view))
    }

    let translationStub = Stub<UIView?, CGPoint>(defaultReturnValue: .zero)
    override func translation(in view: UIView?) -> CGPoint {
        translationStub.call(with: view)
    }

    let getViewStub = Stub<Void, UIView?>(defaultReturnValue: nil)
    override var view: UIView? {
        getViewStub.call()
    }

    let getNumberOfTouchesStub = Stub<Void, Int>(defaultReturnValue: 0)
    override var numberOfTouches: Int {
        getNumberOfTouchesStub.call()
    }
}
