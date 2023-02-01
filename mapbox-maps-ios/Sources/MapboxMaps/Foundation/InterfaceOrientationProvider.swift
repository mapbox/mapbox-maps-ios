import Foundation
import UIKit
import CoreLocation

/// A protocol that supplies current interface orientation for the specified view.
///
/// Use this protocol when the map view is used in non-application target (e.g. application extension target).
@available(iOS, deprecated: 13)
public protocol InterfaceOrientationProvider {

    /// Asks the provider for the interface orientation of the provided view.
    ///
    /// When a device is rotated map view passes current interface orientation to its location producer in order to ensure heading is displayed correctly.
    /// - Parameters:
    ///   - view: The view to get interface orientation from.
    /// - Returns: The interface orientation for the provided view.
    func interfaceOrientation(for view: UIView) -> UIInterfaceOrientation?
}

extension InterfaceOrientationProvider {
    internal func headingOrientation(for view: UIView) -> CLDeviceOrientation? {
        // locationProvider.headingOrientation should be adjusted based on the
        // current UIInterfaceOrientation of the containing window, not the
        // device orientation
        guard let interfaceOrientation = interfaceOrientation(for: view) else {
            return nil
        }

        return CLDeviceOrientation(interfaceOrientation: interfaceOrientation)
    }
}

@available(iOS, deprecated: 13)
@available(iOSApplicationExtension, unavailable)
internal final class UIApplicationInterfaceOrientationProvider: InterfaceOrientationProvider {
    private let application: UIApplicationProtocol

    init(application: UIApplicationProtocol = UIApplication.shared) {
        self.application = application
    }

    func interfaceOrientation(for view: UIView) -> UIInterfaceOrientation? {
        return application.statusBarOrientation
    }
}

@available(iOS 13.0, *)
internal final class DefaultInterfaceOrientationProvider: InterfaceOrientationProvider {
    func interfaceOrientation(for view: UIView) -> UIInterfaceOrientation? {
        return view.window?.windowScene?.interfaceOrientation
    }
}

internal extension CLDeviceOrientation {
    init(interfaceOrientation: UIInterfaceOrientation) {
        // UIInterfaceOrientation.landscape{Right,Left} correspond to
        // CLDeviceOrientation.landscape{Left,Right}, respectively. The reason
        // for this, according to the UIInterfaceOrientation docs is that
        //
        //    > …rotating the device requires rotating the content in the
        //    > opposite direction.
        switch interfaceOrientation {
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        default:
            self = .portrait
        }
    }
}
