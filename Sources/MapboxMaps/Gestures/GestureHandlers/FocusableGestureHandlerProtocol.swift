import Foundation

internal protocol FocusableGestureHandlerProtocol: GestureHandler {
    var focalPoint: CGPoint? { get set }
}
