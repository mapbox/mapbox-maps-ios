import UIKit
import MapboxCoreMaps
import MapboxMaps
import MapboxMapsFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        return true
    }
}

class ViewController:  UIViewController {
    var mapView: MapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView(with: UIScreen.main.bounds, resourceOptions: ResourceOptions(accessToken: "<#token#>"))
        view.addSubview(mapView)
    }
}
