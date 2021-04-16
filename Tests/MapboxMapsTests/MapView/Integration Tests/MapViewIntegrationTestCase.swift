import XCTest
import MapboxMaps
import MetalKit

internal class MapViewIntegrationTestCase: IntegrationTestCase {
    internal var mapView: MapView?
    internal var style: Style?

    /// Closures for map view delegate 
    internal var didFinishLoadingStyle: ((MapView) -> Void)?
    internal var didBecomeIdle: ((MapView) -> Void)?
    internal var didFailLoadingMap: ((MapView, NSError) -> Void)?

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        guard let window = window,
              let rootView = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }

        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let view = MapView(frame: window.bounds, mapInitOptions: mapInitOptions, styleURI: nil)

        view.on(.styleLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.didFinishLoadingStyle?(self.mapView!)
        }

        view.on(.mapIdle) { [weak self] _ in
            guard let self = self else { return }
            self.didBecomeIdle?(self.mapView!)
        }

        view.on(.mapLoadingError) { [weak self] event in
            guard let self = self else { return }

            let userInfo: [String: Any] = (event.data as? [String: Any]) ?? [:]
            let error = NSError(domain: "MapLoadError", code: -1, userInfo: userInfo)
            self.didFailLoadingMap?(self.mapView!, error)
        }

        style = view.style

        rootView.addSubview(view)

        view.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true

        mapView = view
    }

    internal override func tearDownWithError() throws {
        mapView?.removeFromSuperview()
        mapView = nil
        style = nil

        rootViewController?.viewWillDisappear(false)
        rootViewController?.viewDidDisappear(false)
        rootViewController = nil
        window = nil
    }
}

// TODO: Cleanup & move the follow somewhere more appropriate
extension MapView {
    func snapshot() -> UIImage? {
        // Calling mapView.layer.render(in:) isn't sufficient for
        // capturing the Metal rendering. This is modified from
        // https://stackoverflow.com/a/47632198 and might not be
        // sufficient.

        guard let metalView = subviews.first as? MTKView,
              let texture = metalView.currentDrawable?.texture else {
            return nil
        }

        guard let ciImage = CIImage(mtlTexture: texture, options: nil),
              let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        // Need to check what the metal view is setting for scale.
        let mapViewSnapshot = UIImage(cgImage: cgImage, scale: 2.0, orientation: .downMirrored)

        // For other subviews, we *can* use render(in:). Again, check scale factor.
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        mapViewSnapshot.draw(at: .zero)
        layer.render(in: context!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return snapshot
    }
}
