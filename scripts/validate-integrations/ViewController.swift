import Foundation
import UIKit
import MapboxMaps

class ViewController: UIViewController {
    let mapView: UIView = MapView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mapView.frame = view.bounds
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func applicationDidFinishLaunching(_ application: UIApplication) {
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
