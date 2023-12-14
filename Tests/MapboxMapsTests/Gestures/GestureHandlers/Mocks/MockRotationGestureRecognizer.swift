import UIKit

final class MockRotationGestureRecognizer: UIRotationGestureRecognizer {
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

    let getVelocityStub = Stub<Void, CGFloat>(defaultReturnValue: 0)
    override var velocity: CGFloat {
        get {
            getVelocityStub()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }

    let getRotationStub = Stub<Void, CGFloat>(defaultReturnValue: 0)
    let setRotationStub = Stub<CGFloat, Void>()
    override var rotation: CGFloat {
        get { getRotationStub() }
        set { setRotationStub(with: newValue) }
    }

    let locationInViewStub = Stub<UIView?, CGPoint>(defaultReturnValue: .zero)
    override func location(in view: UIView?) -> CGPoint {
        locationInViewStub.call(with: view)
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
