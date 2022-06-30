import Foundation
@testable import MapboxMaps

final class MockRotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
    var rotateEnabled: Bool = true
}
