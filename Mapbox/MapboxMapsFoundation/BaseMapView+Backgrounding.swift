import MapboxCommon
import UIKit

// MARK: Handle background rendering
extension BaseMapView {

    func assertIsMainThread() {
        if !Thread.isMainThread {
            preconditionFailure("applicationWillResignActive must be accessed on the main thread.")
        }
    }

    func mapViewDidEnterBackground() {
        self.assertIsMainThread()
        precondition(!self.dormant, "Should not be dormant heading into background.")

        if self.mapViewSupportsBackgroundRendering() { return }

        if self.renderingInInactiveStateEnabled {
            self.stopDisplayLink()
        }

        self.destroyDisplayLink()
        // Do we need to handle pending blocks?
        // how do we delete a metal view?
        guard let metalView = self.subviews.first as? MTKView else { return }
        metalView.delete(nil)

        // Handle non-rendering backgrounding
        // validate location services
        // flush
    }

    func mapViewWillEnterForeground() {
        if self.mapViewSupportsBackgroundRendering() { return }

        // what is the equivalent of createViwe?

        if window?.screen != nil {
            self.validateDisplayLink()

            if self.renderingInInactiveStateEnabled && self.isVisible() {
                self.startDisplayLink()
            }
        }

        self.dormant = false

        // Validate location services

        // Reports events
        // Report number of render errors
    }

    func enableSnapshotView() {
        if self.metalSnapshotView == nil {
            self.metalSnapshotView = UIImageView(frame: self.getMetalView(for: nil)?.frame ?? self.frame)
            self.metalSnapshotView?.autoresizingMask = self.autoresizingMask
            let options = MapSnapshotOptions(size: self.frame.size, resourceOptions: self.resourceOptions ?? ResourceOptions())
            let snapshotter = Snapshotter(options: options)
            snapshotter.camera = self.cameraView.camera

            snapshotter.start(overlayHandler: nil) { [weak self] (result) in
                guard let self = self else { return }
                self.metalSnapshotView?.image = try? result.get()
            }
        }

        self.metalSnapshotView?.isHidden = false
        self.metalSnapshotView?.alpha = 1
        self.metalSnapshotView?.isOpaque = false

        // Handle a debug mask if applicable
    }

    func resumeRenderingIfNecessary() {
        let applicationState : UIApplication.State = UIApplication.shared.applicationState

        if self.dormant == true {
            // create a view
            self.dormant = false
        }

        if self.displayLink != nil {
            if self.windowScreen() != nil {
                self.createDisplayLink()
            }
        }

        if applicationState == .active || (applicationState == .inactive && self.renderingInInactiveStateEnabled) {
            let mapViewVisible = self.isVisible()
            if self.displayLink != nil {
                if mapViewVisible && self.displayLink?.isPaused == true  {
                    self.startDisplayLink()
                }
                else if !mapViewVisible && self.displayLink?.isPaused != true {
                    // Unlikely scenario
                    self.stopDisplayLink()
                }
            }
        }

        if self.metalSnapshotView != nil && self.metalSnapshotView?.isHidden != true {
            UIView .transition(with: self, duration: 0.25, options: .transitionCrossDissolve) { [weak self] in
                guard let self = self else { return }
                self.metalSnapshotView?.isHidden = true
            } completion: { [weak self] (finished) in
                guard let self = self else { return }
                let subviews = self.metalSnapshotView?.subviews
                subviews?.forEach { $0.removeFromSuperview() }
            }

        }
    }
}

@available(iOS 13, *)
extension BaseMapView: UISceneDelegate {
    public func sceneWillEnterForeground(_ scene: UIScene) {
        self.mapViewWillEnterForeground()
    }

    public func sceneDidBecomeActive(_ scene: UIScene) {
        self.resumeRenderingIfNecessary()
    }

    public func sceneDidEnterBackground(_ scene: UIScene) {
        mapViewDidEnterBackground()
    }
}

extension BaseMapView: UIApplicationDelegate {
    public func applicationWillEnterForeground(_ application: UIApplication) {
        self.mapViewWillEnterForeground()
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        self.resumeRenderingIfNecessary()
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        self.assertIsMainThread()

        if self.renderingInInactiveStateEnabled || self.mapViewSupportsBackgroundRendering() {
            return
        }

        self.stopDisplayLink()
        // We want to reduce memory usage before the map goes into the background
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        mapViewDidEnterBackground()
    }
}

