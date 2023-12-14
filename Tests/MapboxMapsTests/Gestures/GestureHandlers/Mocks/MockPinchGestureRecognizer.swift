import UIKit

final class MockPinchGestureRecognizer: UIPinchGestureRecognizer {
    let getStateStub = Stub<Void, UIGestureRecognizer.State>(defaultReturnValue: .possible)
    override var state: UIGestureRecognizer.State {
        get {
            getStateStub.call()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }

    @Stubbed var viewStub = UIView()
    override var view: UIView {
        get { $viewStub.wrappedValue }
        set { $viewStub.wrappedValue  = newValue }
    }

    let getScaleStub = Stub<Void, CGFloat>(defaultReturnValue: 1)
    let setScaleStub = Stub<CGFloat, Void>()
    override var scale: CGFloat {
        get {
            getScaleStub.call()
        }
        set {
            setScaleStub.call(with: newValue)
        }
    }

    let getNumberOfTouchesStub = Stub<Void, Int>(defaultReturnValue: 2)
    override var numberOfTouches: Int {
        getNumberOfTouchesStub.call()
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
        locationOfTouchStub.call(
            with: LocationOfTouchParams(
                touchIndex: touchIndex,
                view: view))
    }

    struct AddTargetParams {
        var target: Any
        var action: Selector
    }
    let addTargetStub = Stub<AddTargetParams, Void>()
    override func addTarget(_ target: Any, action: Selector) {
        addTargetStub.call(with: AddTargetParams(target: target, action: action))
    }

    func sendActions() {
        for param in addTargetStub.invocations.map(\.parameters) {
            (param.target as? NSObject)?.perform(param.action, with: self)
        }
    }
}
