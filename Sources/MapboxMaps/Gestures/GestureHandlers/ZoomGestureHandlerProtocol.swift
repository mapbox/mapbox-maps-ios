import Foundation

internal protocol ZoomGestureHandlerProtocol: GestureHandler {
    var focalPoint: CGPoint? { get set }
}
