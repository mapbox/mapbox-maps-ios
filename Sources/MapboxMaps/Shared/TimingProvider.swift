import Foundation

#if os(OSX)
public enum UITimingCurveType : Int, @unchecked Sendable {
    case builtin = 0

    case cubic = 1

    case spring = 2

    case composed = 3
}

public protocol UITimingCurveProvider : NSCoding, NSCopying {
    var timingCurveType: UITimingCurveType { get }

//    var cubicTimingParameters: UICubicTimingParameters? { get }
//
//    var springTimingParameters: UISpringTimingParameters? { get }
}

//public class UICubicTimingParameters : NSObject, UITimingCurveProvider {
//    public init(animationCurve: View.AnimationCurve, controlPoint1: CGPoint, controlPoint2: CGPoint) {
//        self.animationCurve = animationCurve
//        self.controlPoint1 = controlPoint1
//        self.controlPoint2 = controlPoint2
//    }
//
//
//
//    open var animationCurve: View.AnimationCurve
//
//    open var controlPoint1: CGPoint
//
//    open var controlPoint2: CGPoint
//}
//
//public class UISpringTimingParameters : NSObject, UITimingCurveProvider {
//    open var dampingRation: CGFloat?
//    open var initialVelocity: CGVector
//
//
//    // Performs `animations` using a timing curve described by the motion of a
//    // spring. When `dampingRatio` is 1, the animation will smoothly decelerate to
//    // its final model values without oscillating. Damping ratios less than 1 will
//    // oscillate more and more before coming to a complete stop. You can use the
//    // initial spring velocity to specify how fast the object at the end of the
//    // simulated spring was moving before it was attached. It's a unit coordinate
//    // system, where 1 is defined as traveling the total animation distance in a
//    // second. So if you're changing an object's position by 200pt in this
//    // animation, and you want the animation to behave as if the object was moving
//    // at 100pt/s before the animation started, you'd pass 0.5. You'll typically
//    // want to pass 0 for the velocity. Velocity is specified as a vector for the
//    // convenience of animating position changes. For 1-dimensional properties
//    // the x-coordinate of the velocity vector is used.
//    public init(dampingRatio ratio: CGFloat, initialVelocity velocity: CGVector) {
//        self.dampingRation = ratio
//        self.initialVelocity = velocity
//    }
//
//
//    // Similar to initWithDampingRatio:initialVelocity: except this allows you to specify the spring constants for the underlying
//    // CASpringAnimation directly. The duration is computed assuming a small settling oscillation.
////    public init(mass: CGFloat, stiffness: CGFloat, damping: CGFloat, initialVelocity velocity: CGVector)
//
//
//    // Equivalent to initWithDampingRatio:initialVelocity: where the velocity is the zero-vector.
////    public convenience init(dampingRatio ratio: CGFloat)
//}
//

#endif
