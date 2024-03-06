import Foundation
import UIKit
import MapboxMaps

class ViewController: UIViewController {
    let mapView = MapView(frame: .zero)
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.showAlert(text: "Loaded")
        }.store(in: &cancelables)

        mapView.mapboxMap.onMapLoadingError.observeNext { _ in
            self.showAlert(text: "Failed")
        }.store(in: &cancelables)
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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func applicationDidFinishLaunching(_ application: UIApplication) {
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
