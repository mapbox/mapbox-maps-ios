import UIKit

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

    func applyDarkNavigationBarOniOS26AndAbove() {
        if #available(iOS 26, *) {
            navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
        }
    }

    func resetDarkNavigationBarOniOS26AndAbove() {
        if #available(iOS 26, *) {
            navigationController?.navigationBar.overrideUserInterfaceStyle = .unspecified
        }
    }

    // Present an alert with a given title and message.
    func showAlert(withTitle title: String, and message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
