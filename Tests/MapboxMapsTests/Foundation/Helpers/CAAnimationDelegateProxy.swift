import QuartzCore
import os

final class CAAnimationDelegateProxy: NSObject, CAAnimationDelegate {
    var animationStart: ((_ animation: CAAnimation) -> Void)?
    var animationStop: ((_ animation: CAAnimation, _ finished: Bool) -> Void)?

    init(animationStop: ((_: CAAnimation, _: Bool) -> Void)? = nil) {
        self.animationStop = animationStop
    }

    func animationDidStart(_ anim: CAAnimation) {
        os_log(.info, #function)
        animationStart?(anim)
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        os_log(.info, #function)
        animationStop?(anim, flag)
    }
}
