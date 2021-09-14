import UIKit

final class MockTapGestureRecognizer: UITapGestureRecognizer {
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
