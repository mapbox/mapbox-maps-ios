import Foundation
import UIKit
import CoreLocation
import Combine

/// A protocol that supplies current interface orientation for the map view.
///
/// Use this protocol when the map view is used in non-application target (e.g. application extension target).
@available(iOS, deprecated: 13)
public protocol InterfaceOrientationProvider {
    /// Returns the current interface orientation
    var interfaceOrientation: UIInterfaceOrientation { get }

    /// Asks the provider for the interface orientation of the map view.
    ///
    /// When a device is rotated map view passes current interface orientation to its location provider in order to ensure heading is displayed correctly.
    var onInterfaceOrientationChange: Signal<UIInterfaceOrientation> { get }
}

internal final class DefaultInterfaceOrientationProvider: InterfaceOrientationProvider {
    var onInterfaceOrientationChange: Signal<UIInterfaceOrientation> { orientationChangeSubject.signal }

    private lazy var orientationChangeSubject = SignalSubject<UIInterfaceOrientation>(onObserved: { [weak self] beingObserved in
        self?.isUpdating = beingObserved
    })

    var interfaceOrientation: UIInterfaceOrientation {
        let view = userInterfaceOrientationView.value
        let orientation: UIInterfaceOrientation

        if #available(iOS 13.0, *) {
            orientation = view?.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            orientation = UIInterfaceOrientation(deviceOrientation: device.orientation)
        }

        return orientation
    }

    private let userInterfaceOrientationView: Ref<UIView?>
    private let notificationCenter: NotificationCenterProtocol
    private let device: UIDeviceProtocol
    private var isUpdating = false {
        didSet {
            if isUpdating {
                startUpdatingInterfaceOrientation()
            } else {
                stopUpdatingInterfaceOrientation()
            }
        }
    }

    internal init(userInterfaceOrientationView: Ref<UIView?>,
                  notificationCenter: NotificationCenterProtocol,
                  device: UIDeviceProtocol) {
        self.notificationCenter = notificationCenter
        self.device = device
        self.userInterfaceOrientationView = userInterfaceOrientationView
    }

    private func startUpdatingInterfaceOrientation() {
        device.beginGeneratingDeviceOrientationNotifications()
        notificationCenter.addObserver(self,
                                       selector: #selector(deviceOrientationDidChange),
                                       name: UIDevice.orientationDidChangeNotification,
                                       object: nil)
    }

    private func stopUpdatingInterfaceOrientation() {
        device.endGeneratingDeviceOrientationNotifications()
        notificationCenter.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        orientationChangeSubject.send(interfaceOrientation)
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

internal extension UIInterfaceOrientation {
    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            self = .portrait
        }
    }
}
