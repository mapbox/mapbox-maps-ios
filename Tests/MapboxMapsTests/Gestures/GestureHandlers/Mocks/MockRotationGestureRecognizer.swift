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
