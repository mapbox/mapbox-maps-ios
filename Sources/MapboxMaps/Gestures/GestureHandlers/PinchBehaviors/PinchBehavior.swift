internal protocol PinchBehavior: AnyObject {
    func update(pinchMidpoint: CGPoint, pinchScale: CGFloat)
}
