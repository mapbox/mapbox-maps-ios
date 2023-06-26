import Foundation
import UIKit

internal protocol UIDeviceProtocol: AnyObject {
    var orientation: UIDeviceOrientation { get }

    func beginGeneratingDeviceOrientationNotifications()
    func endGeneratingDeviceOrientationNotifications()
}

extension UIDevice: UIDeviceProtocol { }
