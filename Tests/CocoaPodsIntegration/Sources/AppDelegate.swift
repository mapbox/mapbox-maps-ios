import UIKit
import MapboxMaps
import CMapbox
import Gestures

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        return true
    }
}

class ViewController: UIViewController {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let token = "<#Mapbox Access Token Here#>"
        mapView = MapView(frame: view.bounds, accessToken: token)

        view.addSubview(mapView)
    }

}
