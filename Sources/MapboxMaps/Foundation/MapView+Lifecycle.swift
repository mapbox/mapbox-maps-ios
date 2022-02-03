import Foundation
import UIKit

@available(iOSApplicationExtension, unavailable)
extension MapView {
    private static let UIApplicationSceneManifestKey = "UIApplicationSceneManifest"

    internal func subscribeToMemoryWarningNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }

    internal func subscribeToLifecycleNotifications() {
        if Bundle.main.object(forInfoDictionaryKey: MapView.UIApplicationSceneManifestKey) != nil {
            if #available(iOS 13.0, *) {
                subscribeToSceneLifecycleNotifications()
            }
        } else {
            subscribeToApplicationsLifecycleNotifications()
        }
    }

    internal func unsubscribeFromLifecycleNotifications() {
        if Bundle.main.object(forInfoDictionaryKey: MapView.UIApplicationSceneManifestKey) != nil {
            if #available(iOS 13.0, *) {
                NotificationCenter.default.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
            }
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }

    @objc internal func didReceiveMemoryWarning() {
        mapboxMap.reduceMemoryUse()
    }

    @objc internal func willEnterForeground() {
        resumeDisplayLink()
    }

    @objc internal func didEnterBackground() {
        mapboxMap.reduceMemoryUse()
        pauseDisplayLink()
    }

    @available(iOS 13.0, *)
    @objc private func didReceiveSceneLifecycleNotification(_ notification: Notification) {
        // making sure the scene is the correct one, as the scene may not be available when subscribing
        guard let scene = notification.object as? UIScene, scene == window?.parentScene else {
            return
        }

        switch notification.name {
        case UIScene.willEnterForegroundNotification:
            willEnterForeground()
        case UIScene.didEnterBackgroundNotification:
            didEnterBackground()
        default:
            break
        }
    }

    @available(iOS 13.0, *)
    private func subscribeToSceneLifecycleNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIScene.willEnterForegroundNotification,
                                               object: window?.parentScene)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIScene.didEnterBackgroundNotification,
                                               object: window?.parentScene)
    }

    private func subscribeToApplicationsLifecycleNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
}
