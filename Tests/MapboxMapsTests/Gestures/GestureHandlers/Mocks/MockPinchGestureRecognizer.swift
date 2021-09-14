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

    struct AddTargetParams {
        var target: Any
        var action: Selector
    }
    let addTargetStub = Stub<AddTargetParams, Void>()
    override func addTarget(_ target: Any, action: Selector) {
        addTargetStub.call(with: AddTargetParams(target: target, action: action))
    }

    func sendActions() {
        for param in addTargetStub.parameters {
            (param.target as? NSObject)?.perform(param.action, with: self)
        }
    }
}
