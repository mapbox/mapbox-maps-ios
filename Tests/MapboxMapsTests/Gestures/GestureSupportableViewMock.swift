import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl large_tuple
// Mock class that flags true when `GestureSupportableView` protocol methods have been called on it
class GestureHandlerDelegateMock: GestureHandlerDelegate {

    var gestureBeganMethod: (wasCalled: Bool, type: GestureType?) = (false, nil)

    func gestureBegan(for gestureType: GestureType) {
        gestureBeganMethod.wasCalled = true
        gestureBeganMethod.type = gestureType
    }
}
