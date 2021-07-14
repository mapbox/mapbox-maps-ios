#  Add to your AppDelegate file

import MapboxMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ResourceOptionsManager.default.resourceOptions.accessToken = "{YOUR ACCESS TOKEN}"
        return true
    }
}
