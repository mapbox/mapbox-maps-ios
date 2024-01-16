import UIKit

extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        var result = self
        while let presented = result.presentedViewController {
            result = presented
        }
        return result
    }
}
