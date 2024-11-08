import UIKit
import Fingertips
import OSLog
@_spi(Experimental) import MapboxMaps
@_spi(Experimental) import MapboxCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var geofencing = GeofencingFactory.getOrCreate()

    lazy var window: UIWindow? = {
        return FingerTipWindow(frame: UIScreen.main.bounds)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LogConfiguration.setLoggingLevelForUpTo(0)
        geofencing.addObserver(observer: self, callback: { result in
            switch result {
            case .success:
                os_log(.info, "Geofencing: Observer added properly")
            case .failure(let error):
                os_log(.error, "Geofencing: Error while adding observer %@", error.message)
            }
        })

        UNUserNotificationCenter.current().delegate = self

        let appearance = UINavigationBar.appearance()
        appearance.prefersLargeTitles = true

        if #available(iOS 13.0, *) {
            appearance.scrollEdgeAppearance = UINavigationBarAppearance()
        }

        if #unavailable(iOS 13.0) {
            let examplesTableViewController = ExampleTableViewController()
            let navigationController = UINavigationController(rootViewController: examplesTableViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }

        return true
    }
}

extension AppDelegate: GeofencingObserver {
    func onExit(event: MapboxCommon.GeofencingEvent) {
        sendNotification(action: "Exited", event: event)
    }
    func onEntry(event: MapboxCommon.GeofencingEvent) {
        sendNotification(action: "Entered", event: event)
    }
    func onDwell(event: MapboxCommon.GeofencingEvent) {
        sendNotification(action: "Dwelled", event: event)
    }
    func onError(error: MapboxCommon.GeofencingError) {}

    func onUserConsentChanged(isConsentGiven: Bool) {
        print("onUserConsentChanged(), isConsentGiven is \(isConsentGiven)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func formateDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current

        return dateFormatter.string(for: date)!
    }

    private func sendNotification(action: String, event: GeofencingEvent) {
        guard case let .string(id) = event.feature.identifier
        else { return }

        os_log(.debug, "AppDelegate.sendNotification() action: %s, event: %s", action, id)
        let date = formateDate(date: event.timestamp)
        let content = UNMutableNotificationContent()
        content.title = "\(action) \(id)"
        content.subtitle = "\(date)"
        content.sound = UNNotificationSound.default
        content.userInfo["featureId"] = id
        content.userInfo["action"] = action

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // show the notification alert (banner), and with sound
        completionHandler([.alert, .sound])
    }

    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        os_log(.debug, "AppDelegate.userNotificationCenter didReceive")
        let application = UIApplication.shared
        if application.applicationState == .active {
            os_log(.debug, "AppDelegate user tapped the notification bar when the app is in foreground")
        }
        if application.applicationState == .inactive {
            os_log(.debug, "AppDelegate user tapped the notification bar when the app is in background")
        }
        let content = response.notification.request.content
        let featureId = content.userInfo["featureId"]! as! String
        let action = content.userInfo["action"]! as! String
        os_log(.info, "AppDelegate Got %s for feature %s", action, featureId)

        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
}

@available(iOS 13.0, *)
final class SceneDelegate: NSObject, UISceneDelegate {
    var windows: [UIWindow] = []

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = FingerTipWindow(windowScene: windowScene)

        let examplesTableViewController = ExampleTableViewController()
        let navigationController = UINavigationController(rootViewController: examplesTableViewController)

        let appearance = UINavigationBar.appearance()
        appearance.prefersLargeTitles = true

        appearance.scrollEdgeAppearance = UINavigationBarAppearance()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        windows.append(window)
    }
}
