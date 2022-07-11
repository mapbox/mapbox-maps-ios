import CoreGraphics
internal protocol PinchBehavior: AnyObject {
    func update(pinchMidpoint: CGPoint, pinchScale: CGFloat, handler: RotateGestureHandler)
}
