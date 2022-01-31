import Foundation

@available(iOSApplicationExtension, unavailable)
extension MapView {

    internal func subscribeToLifecycleNotifications() {
        // Subscribing here to both UIApplication and UIScene lifecycle events
        // as they are mutually exclusive, depending on the presense of `UIApplicationSceneManifest`
        // key in the Info.plist configuration file
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(willEnterForeground),
                                                   name: UIScene.willEnterForegroundNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didEnterBackground),
                                                   name: UIScene.didEnterBackgroundNotification,
                                                   object: nil)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }

    @objc func didReceiveMemoryWarning() {
        mapboxMap.reduceMemoryUse()
    }

    @objc func willEnterForeground() {
        resumeDisplayLink()
    }

    @objc func didEnterBackground() {
        pauseDisplayLink()
    }
}
