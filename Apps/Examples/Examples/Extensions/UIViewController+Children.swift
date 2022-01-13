#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension UIViewController {
    internal func addChildViewController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    internal func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
