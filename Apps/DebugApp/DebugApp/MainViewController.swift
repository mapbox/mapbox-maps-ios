import UIKit

class MainViewController: UIViewController {

    // Show the existing view controller immediately, unless we're testing
    // in which case, let the XCTest handle that.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserDefaults.standard.bool(forKey: "testing") {
            DispatchQueue.main.async {
                self.showViewController()
            }
        }
    }

    // Show the view controller modally (fullscreen). The test is expected to dismiss the view controller using
    // viewController.dismiss(animated:completion:)
    func showViewController<T: UIViewController>(withIdentifier identifier: String, type: T.Type = T.self, completion: ((T) -> Void)? = nil) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("DebugViewController should have an identifier")
        }

        vc.modalPresentationStyle = .fullScreen

        present(vc, animated: false) {
            completion?(vc)
        }
    }

    @IBAction func showViewController() {
        self.showViewController(withIdentifier: "viewControllerId", type: DebugViewController.self)
    }
}
