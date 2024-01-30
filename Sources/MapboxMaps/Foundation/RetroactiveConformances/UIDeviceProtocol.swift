import Foundation
import UIKit

internal protocol UIDeviceProtocol: AnyObject {
    var orientation: UIDeviceOrientation { get }

    func beginGeneratingDeviceOrientationNotifications()
    func endGeneratingDeviceOrientationNotifications()
}

#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
extension UIDevice: UIDeviceProtocol { }
