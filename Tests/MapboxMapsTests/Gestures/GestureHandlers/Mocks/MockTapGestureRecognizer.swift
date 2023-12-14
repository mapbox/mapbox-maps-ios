import UIKit

final class MockTapGestureRecognizer: UITapGestureRecognizer {
    struct AddTargetParams {
        var target: Any
        var action: Selector
    }

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

    let addTargetStub = Stub<AddTargetParams, Void>()
    override func addTarget(_ target: Any, action: Selector) {
        addTargetStub(with: AddTargetParams(target: target, action: action))
    }

    func sendActions() {
        for param in addTargetStub.invocations.map(\.parameters) {
            (param.target as? NSObject)?.perform(param.action, with: self)
        }
    }

    let locationStub = Stub<UIView?, CGPoint>(defaultReturnValue: .random())
    override func location(in view: UIView?) -> CGPoint {
        locationStub(with: view)
    }
}
