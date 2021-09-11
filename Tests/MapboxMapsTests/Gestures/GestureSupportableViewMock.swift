import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl large_tuple
// Mock class that flags true when `GestureSupportableView` protocol methods have been called on it
class GestureHandlerDelegateMock: GestureHandlerDelegate {

    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    var rotationChangedMethod: (wasCalled: Bool, newAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)
    var rotationEndedMethod: (wasCalled: Bool, finalAngle: CGFloat?, anchor: CGPoint?) = (false, nil, nil)

    func gestureBegan(for gestureType: GestureType) {
        gestureBeganMethod.wasCalled = true
        gestureBeganMethod.type = gestureType
    }

    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {
        rotationChangedMethod.wasCalled = true
        rotationChangedMethod.newAngle = changedAngle
        rotationChangedMethod.anchor = anchor
    }

    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        rotationEndedMethod.wasCalled = true
        rotationEndedMethod.finalAngle = finalAngle
        rotationEndedMethod.anchor = anchor
    }
}
