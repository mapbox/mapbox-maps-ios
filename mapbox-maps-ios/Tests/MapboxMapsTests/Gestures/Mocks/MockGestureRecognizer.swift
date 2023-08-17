import UIKit

final class MockGestureRecognizer: UIGestureRecognizer {
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

    let requireToFailStub = Stub<UIGestureRecognizer, Void>()
    override func require(toFail otherGestureRecognizer: UIGestureRecognizer) {
        requireToFailStub.call(with: otherGestureRecognizer)
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
            _ = (param.target as AnyObject).perform(param.action, with: self)
        }
    }

    var mockLocation: CGPoint?
    override func location(in view: UIView?) -> CGPoint {
        if let mockLocation, view == self.view {
            return mockLocation
        } else {
            return super.location(in: view)
        }
    }
}
