import Foundation
import UIKit
import CoreLocation

internal final class DefaultInterfaceOrientationProvider {
    var onInterfaceOrientationChange: Signal<UIInterfaceOrientation> { subject.signal }

    private lazy var subject: CurrentValueSignalSubject<UIInterfaceOrientation> = {
        let subject = CurrentValueSignalSubject(calculateInterfaceOrientation())
        subject.onObserved = { [weak self] observed in
            if observed {
                self?.startUpdatingInterfaceOrientation()
            } else {
                self?.stopUpdatingInterfaceOrientation()
            }
        }
        return subject
    }()

    private let userInterfaceOrientationView: Ref<UIView?>
    private let notificationCenter: NotificationCenterProtocol
    private let device: UIDeviceProtocol

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
        subject.value = calculateInterfaceOrientation()
    }

    private func calculateInterfaceOrientation() -> UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            let view = userInterfaceOrientationView.value
            return view?.window?.windowScene?.interfaceOrientation ?? .unknown
        }
        return UIInterfaceOrientation(deviceOrientation: device.orientation)
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
