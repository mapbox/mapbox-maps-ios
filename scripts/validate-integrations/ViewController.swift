import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import MapboxMaps

class ViewController: UIViewController {
    let mapView = MapView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.showAlert(text: "Loaded")
        }

        mapView.mapboxMap.onNext(.mapLoadingError) { _ in
            self.showAlert(text: "Failed")
        }
    }

    func showAlert(text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction())
        alert.accessibilityLabel = "custom-alert"

        show(alert, sender: self)
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
