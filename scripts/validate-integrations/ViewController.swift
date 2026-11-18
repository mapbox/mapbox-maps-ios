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
class AppDelegate: UIResponder, UIApplicationDelegate {}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
